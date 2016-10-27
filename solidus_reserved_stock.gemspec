# coding: utf-8
lib = File.expand_path("../lib/", __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require "solidus_reserved_stock/version"

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "solidus_reserved_stock"
  s.version     = SolidusReservedStock.version
  s.homepage    = "https://github.com/resolve/solidus_reserved_stock"
  s.license     = "MIT"
  s.summary     = <<-HEREDOC
Allows stock to be reserved for a given user, so it can't be purchased by other
users.
                  HEREDOC
  s.description = <<-HEREDOC
Allow stock to be reserved for a given user, so it can't be purchased by other
users.
When a customer reserves stock, it's moved from its normal stock location to a
special reserved stock location. When a customer checks out, their reserved
items will be used first to fulfill their order.
Reserved stock can be restored to its original stock location at any time, and
can be stored with an expiry date for the reservation.
                  HEREDOC

  s.author      = "Isaac Freeman"
  s.email       = "isaac@resolvedigital.co.nz"

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_path = "lib"
  s.requirements << "none"

  s.has_rdoc = false

  s.add_runtime_dependency "solidus_api", "~> 2.0"
  s.add_runtime_dependency "solidus_backend", "~> 2.0"
  s.add_runtime_dependency "solidus_core", "~> 2.0"
  s.add_runtime_dependency "deface", "~> 1.0"

  s.add_development_dependency "awesome_print"
  s.add_development_dependency "byebug", "~> 9.0"
  s.add_development_dependency "capybara", "~> 2.10"
  s.add_development_dependency "coffee-rails", "~> 4.2"
  s.add_development_dependency "database_cleaner", "~> 1.5"
  s.add_development_dependency "factory_girl_rails", "~> 4.7"
  s.add_development_dependency "ffaker", "~> 2.2"
  s.add_development_dependency "guard-rspec", "~> 4.7"
  s.add_development_dependency "poltergeist", "~> 1.11"
  s.add_development_dependency "pry-rails", "~> 0.3"
  s.add_development_dependency "rspec-activemodel-mocks", "~> 1.0"
  s.add_development_dependency "rspec-rails", "~> 3.5"
  s.add_development_dependency "rubocop", "~> 0.44"
  s.add_development_dependency "sass-rails", "~> 5.0"
  s.add_development_dependency "simplecov", "~> 0.12"
end
