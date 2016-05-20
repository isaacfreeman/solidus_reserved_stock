source "https://rubygems.org"

gem "solidus", github: "solidusio/solidus", branch: "v1.2"

group :test do
  gem "database_cleaner"
end

gemspec

if ENV["DB"] == "mysql"
  gem "mysql2", "~> 0.3.20"
elsif ENV["DB"] == "postgres"
  gem "pg"
else
  gem "sqlite3", "~> 1.3.10"
end
