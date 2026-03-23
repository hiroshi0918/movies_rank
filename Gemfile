source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.7"

gem "bootsnap", ">= 1.18", require: false
gem "devise", "~> 5.0"
gem "ffi", ">= 1.17.1"
gem "font-awesome-sass", "~> 5.15"
gem "image_processing", "~> 1.2"
gem "jbuilder", "~> 2.14"
gem "jquery-rails", "~> 4.6"
gem "kaminari", "~> 1.2"
gem "mysql2", "~> 0.5.7"
gem "puma", "~> 6.6"
gem "rails", "8.1.2"
gem "sassc-rails"
gem "sprockets-rails", "~> 3.5"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw], require: "debug/prelude"
end

group :development do
  gem "listen", ">= 3.9"
  gem "pry-rails"
  gem "web-console", "~> 4.3"
end

group :test do
  gem "capybara", ">= 3.40"
  gem "selenium-webdriver", ">= 4.41"
end

gem "dotenv-rails", "~> 3.2", groups: [:development, :test]
