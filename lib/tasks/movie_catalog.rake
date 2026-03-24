namespace :movies do
  desc "Backfill catalog titles and posters into existing movies"
  task backfill_catalog: :environment do
    importer = MovieCatalogImporter.new(users: User.order(:id).to_a)
    movies = importer.import!

    puts "Backfilled #{movies.size} catalog movies"
  end
end
