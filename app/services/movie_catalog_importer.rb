require "net/http"
require "stringio"

class MovieCatalogImporter
  def initialize(entries: MovieCatalog.entries, users:, logger: Rails.logger, poster_fetcher: nil)
    @entries = entries
    @users = Array(users)
    @logger = logger
    @poster_fetcher = poster_fetcher || method(:download_poster!)
  end

  def import!
    raise ArgumentError, "users must not be empty" if users.empty?

    entries.each_with_index.map do |entry, index|
      movie = upsert_movie!(entry)
      logger.info("MovieCatalogImporter imported #{index + 1}/#{entries.size}: #{movie.title}")
      movie
    end
  end

  private

  attr_reader :entries, :users, :logger, :poster_fetcher

  def upsert_movie!(entry)
    movie = find_movie(entry) || Movie.new
    needs_poster_refresh = !movie.image.attached? || movie.poster_source_url != entry.fetch(:poster_source_url)
    Movie.transaction do
      movie.assign_attributes(
        title: entry.fetch(:title),
        original_title: entry.fetch(:original_title),
        director: entry.fetch(:director),
        category: entry.fetch(:category),
        detail: entry.fetch(:detail),
        poster_source_url: entry.fetch(:poster_source_url),
        youtube_url: entry[:youtube_url]
      )
      movie.user ||= users.sample
      movie.save!

      refresh_poster!(movie, entry.fetch(:poster_source_url)) if needs_poster_refresh
      movie
    end
  end

  def find_movie(entry)
    original_title = entry.fetch(:original_title)
    Movie.find_by(original_title: original_title) ||
      Movie.find_by(title: original_title) ||
      Movie.find_by(title: entry.fetch(:title))
  end

  def refresh_poster!(movie, poster_source_url)
    attachment = poster_fetcher.call(poster_source_url, filename: poster_filename(movie, poster_source_url))

    movie.image.purge if movie.image.attached?
    movie.image.attach(
      io: attachment.fetch(:io),
      filename: attachment.fetch(:filename),
      content_type: attachment.fetch(:content_type)
    )
    movie.save!
  end

  def poster_filename(movie, poster_source_url)
    extension = File.extname(URI.parse(poster_source_url).path).presence || ".jpg"
    base_name = movie.original_title.presence || movie.title
    "#{base_name.parameterize}#{extension}"
  end

  def download_poster!(poster_source_url, filename:)
    uri = URI.parse(poster_source_url)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 10, read_timeout: 10) do |http|
      http.request_get(uri.request_uri)
    end

    case response
    when Net::HTTPSuccess
      {
        io: StringIO.new(response.body),
        filename: filename,
        content_type: response.content_type || "image/jpeg"
      }
    when Net::HTTPRedirection
      redirected_url = URI.join(poster_source_url, response["location"]).to_s
      download_poster!(redirected_url, filename: filename)
    else
      raise "Poster download failed for #{poster_source_url}: #{response.code}"
    end
  end
end
