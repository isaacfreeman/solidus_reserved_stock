source 'https://rubygems.org'

gemspec

gem 'solidus', github: 'solidusio/solidus', branch: 'v1.2'

if ENV['DB'] == 'mysql'
  gem 'mysql2', '~> 0.3.20'
elsif ENV['DB'] == 'postgres'
  gem 'pg'
else
  gem 'sqlite3', '~> 1.3.10'
end
