require "yaml"

class MovieCatalog
  PATH = Rails.root.join("db/catalog/movies.yml")

  def self.entries(path: PATH)
    YAML.load_file(path).map(&:with_indifferent_access)
  end
end
