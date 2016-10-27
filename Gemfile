source "https://rubygems.org"

gem "solidus", github: "solidusio/solidus", branch: "v2.0"

group :development do
  gem "i18n-tasks"
end

group :test do
  gem "database_cleaner"
end

group :development, :test do
  gem "solidus_product_assembly", "~> 1.0.0"
end

gemspec

if ENV["DB"] == "mysql"
  gem "mysql2", "~> 0.3.20"
elsif ENV["DB"] == "postgres"
  gem "pg"
else
  gem "sqlite3", "~> 1.3.10"
end
