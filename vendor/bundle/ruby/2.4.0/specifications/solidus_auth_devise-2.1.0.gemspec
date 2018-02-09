# -*- encoding: utf-8 -*-
# stub: solidus_auth_devise 2.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "solidus_auth_devise".freeze
  s.version = "2.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Solidus Team".freeze]
  s.date = "2018-01-22"
  s.description = "Provides authentication and authorization services for use with Solidus by using Devise and CanCan.".freeze
  s.email = "contact@solidus.io".freeze
  s.licenses = ["BSD-3".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1".freeze)
  s.requirements = ["none".freeze]
  s.rubygems_version = "2.6.11".freeze
  s.summary = "Provides authentication and authorization services for use with Solidus by using Devise and CanCan.".freeze

  s.installed_by_version = "2.6.11" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<solidus_core>.freeze, ["< 3", ">= 1.2.0"])
      s.add_runtime_dependency(%q<solidus_support>.freeze, [">= 0.1.3"])
      s.add_runtime_dependency(%q<devise>.freeze, ["~> 4.1"])
      s.add_runtime_dependency(%q<devise-encryptable>.freeze, ["= 0.2.0"])
      s.add_development_dependency(%q<capybara>.freeze, ["~> 2.14"])
      s.add_development_dependency(%q<capybara-screenshot>.freeze, [">= 0"])
      s.add_development_dependency(%q<coffee-rails>.freeze, [">= 0"])
      s.add_development_dependency(%q<database_cleaner>.freeze, ["~> 1.6"])
      s.add_development_dependency(%q<factory_bot>.freeze, ["~> 4.4"])
      s.add_development_dependency(%q<ffaker>.freeze, [">= 0"])
      s.add_development_dependency(%q<poltergeist>.freeze, ["~> 1.5"])
      s.add_development_dependency(%q<rspec-rails>.freeze, ["~> 3.3"])
      s.add_development_dependency(%q<sass-rails>.freeze, [">= 0"])
      s.add_development_dependency(%q<shoulda-matchers>.freeze, ["~> 3.1"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.14"])
      s.add_development_dependency(%q<solidus_backend>.freeze, ["< 3", ">= 1.2.0"])
      s.add_development_dependency(%q<solidus_frontend>.freeze, ["< 3", ">= 1.2.0"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
    else
      s.add_dependency(%q<solidus_core>.freeze, ["< 3", ">= 1.2.0"])
      s.add_dependency(%q<solidus_support>.freeze, [">= 0.1.3"])
      s.add_dependency(%q<devise>.freeze, ["~> 4.1"])
      s.add_dependency(%q<devise-encryptable>.freeze, ["= 0.2.0"])
      s.add_dependency(%q<capybara>.freeze, ["~> 2.14"])
      s.add_dependency(%q<capybara-screenshot>.freeze, [">= 0"])
      s.add_dependency(%q<coffee-rails>.freeze, [">= 0"])
      s.add_dependency(%q<database_cleaner>.freeze, ["~> 1.6"])
      s.add_dependency(%q<factory_bot>.freeze, ["~> 4.4"])
      s.add_dependency(%q<ffaker>.freeze, [">= 0"])
      s.add_dependency(%q<poltergeist>.freeze, ["~> 1.5"])
      s.add_dependency(%q<rspec-rails>.freeze, ["~> 3.3"])
      s.add_dependency(%q<sass-rails>.freeze, [">= 0"])
      s.add_dependency(%q<shoulda-matchers>.freeze, ["~> 3.1"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.14"])
      s.add_dependency(%q<solidus_backend>.freeze, ["< 3", ">= 1.2.0"])
      s.add_dependency(%q<solidus_frontend>.freeze, ["< 3", ">= 1.2.0"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<solidus_core>.freeze, ["< 3", ">= 1.2.0"])
    s.add_dependency(%q<solidus_support>.freeze, [">= 0.1.3"])
    s.add_dependency(%q<devise>.freeze, ["~> 4.1"])
    s.add_dependency(%q<devise-encryptable>.freeze, ["= 0.2.0"])
    s.add_dependency(%q<capybara>.freeze, ["~> 2.14"])
    s.add_dependency(%q<capybara-screenshot>.freeze, [">= 0"])
    s.add_dependency(%q<coffee-rails>.freeze, [">= 0"])
    s.add_dependency(%q<database_cleaner>.freeze, ["~> 1.6"])
    s.add_dependency(%q<factory_bot>.freeze, ["~> 4.4"])
    s.add_dependency(%q<ffaker>.freeze, [">= 0"])
    s.add_dependency(%q<poltergeist>.freeze, ["~> 1.5"])
    s.add_dependency(%q<rspec-rails>.freeze, ["~> 3.3"])
    s.add_dependency(%q<sass-rails>.freeze, [">= 0"])
    s.add_dependency(%q<shoulda-matchers>.freeze, ["~> 3.1"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.14"])
    s.add_dependency(%q<solidus_backend>.freeze, ["< 3", ">= 1.2.0"])
    s.add_dependency(%q<solidus_frontend>.freeze, ["< 3", ">= 1.2.0"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
  end
end
