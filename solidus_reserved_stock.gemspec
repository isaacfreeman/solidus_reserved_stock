# coding: utf-8
lib = File.expand_path("../lib/", __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require "solidus_reserved_stock/version"

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "solidus_reserved_stock"
  s.version     = SolidusReservedStock.version
  s.summary     = "Provides locale information for use in Solidus."
  s.description = s.summary

  s.author      = "Isaac Freeman"
  s.email       = "isaac@resolvedigital.co.nz"

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_path = "lib"
  s.requirements << "none"

  s.has_rdoc = false

  s.add_runtime_dependency "solidus_core", "~> 1.2.2"
  s.add_runtime_dependency "solidus_api", "~> 1.2.2"
  s.add_runtime_dependency "solidus_backend", "~> 1.2.2"
  s.add_runtime_dependency "deface"

  s.add_development_dependency "byebug"
  s.add_development_dependency "capybara", "~> 2.4.4"
  s.add_development_dependency "coffee-rails", "~> 4.0.0"
  s.add_development_dependency "database_cleaner", "~> 1.3"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "ffaker", ">= 1.25.0"
  s.add_development_dependency "poltergeist", "~> 1.5"
  s.add_development_dependency "pry-rails", ">= 0.3.0"
  s.add_development_dependency "rubocop", ">= 0.24.1"
  s.add_development_dependency "rspec-rails", "~> 3.1"
  s.add_development_dependency "rspec-activemodel-mocks"
  s.add_development_dependency "sass-rails", "~> 5.0.0"
  s.add_development_dependency "simplecov", "~> 0.9"
  s.add_development_dependency "guard-rspec", ">= 4.2.0"
end
