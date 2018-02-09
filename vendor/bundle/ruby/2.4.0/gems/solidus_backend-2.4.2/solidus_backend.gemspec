# encoding: UTF-8
require_relative '../core/lib/spree/core/version.rb'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_backend'
  s.version     = Spree.solidus_version
  s.summary     = 'Admin interface for the Solidus e-commerce framework.'
  s.description = s.summary

  s.author      = 'Solidus Team'
  s.email       = 'contact@solidus.io'
  s.homepage    = 'http://solidus.io'
  s.license     = 'BSD-3-Clause'

  s.files        = `git ls-files`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.required_ruby_version = '>= 2.2.2'
  s.required_rubygems_version = '>= 1.8.23'

  s.add_dependency 'solidus_api', s.version
  s.add_dependency 'solidus_core', s.version

  s.add_dependency 'sass-rails'
  s.add_dependency 'coffee-rails'
  s.add_dependency 'bourbon', '>= 4', '< 6'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'jquery-ui-rails', '~> 5.0.0'
  s.add_dependency 'font-awesome-rails', '~> 4.0'
  s.add_dependency 'kaminari', '>= 0.17', '< 2.0'
  s.add_dependency 'jbuilder', '~> 2.6'

  s.add_dependency 'handlebars_assets', '~> 0.23'
  s.add_dependency 'autoprefixer-rails', '~> 7.1'
end
