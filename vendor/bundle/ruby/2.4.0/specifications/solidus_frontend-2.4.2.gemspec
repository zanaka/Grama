# -*- encoding: utf-8 -*-
# stub: solidus_frontend 2.4.2 ruby lib

Gem::Specification.new do |s|
  s.name = "solidus_frontend".freeze
  s.version = "2.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.8.23".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Solidus Team".freeze]
  s.date = "2017-12-20"
  s.description = "Cart and storefront for the Solidus e-commerce project.".freeze
  s.email = "contact@solidus.io".freeze
  s.homepage = "http://solidus.io/".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.2".freeze)
  s.requirements = ["none".freeze]
  s.rubygems_version = "2.6.11".freeze
  s.summary = "Cart and storefront for the Solidus e-commerce project.".freeze

  s.installed_by_version = "2.6.11" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<solidus_api>.freeze, ["= 2.4.2"])
      s.add_runtime_dependency(%q<solidus_core>.freeze, ["= 2.4.2"])
      s.add_runtime_dependency(%q<canonical-rails>.freeze, ["~> 0.2.0"])
      s.add_runtime_dependency(%q<jquery-rails>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<sass-rails>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<coffee-rails>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<font-awesome-rails>.freeze, ["~> 4.0"])
      s.add_runtime_dependency(%q<truncate_html>.freeze, [">= 0.9.2", "~> 0.9"])
      s.add_runtime_dependency(%q<kaminari>.freeze, ["< 2.0", ">= 0.17"])
      s.add_development_dependency(%q<capybara-accessible>.freeze, [">= 0"])
    else
      s.add_dependency(%q<solidus_api>.freeze, ["= 2.4.2"])
      s.add_dependency(%q<solidus_core>.freeze, ["= 2.4.2"])
      s.add_dependency(%q<canonical-rails>.freeze, ["~> 0.2.0"])
      s.add_dependency(%q<jquery-rails>.freeze, [">= 0"])
      s.add_dependency(%q<sass-rails>.freeze, [">= 0"])
      s.add_dependency(%q<coffee-rails>.freeze, [">= 0"])
      s.add_dependency(%q<font-awesome-rails>.freeze, ["~> 4.0"])
      s.add_dependency(%q<truncate_html>.freeze, [">= 0.9.2", "~> 0.9"])
      s.add_dependency(%q<kaminari>.freeze, ["< 2.0", ">= 0.17"])
      s.add_dependency(%q<capybara-accessible>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<solidus_api>.freeze, ["= 2.4.2"])
    s.add_dependency(%q<solidus_core>.freeze, ["= 2.4.2"])
    s.add_dependency(%q<canonical-rails>.freeze, ["~> 0.2.0"])
    s.add_dependency(%q<jquery-rails>.freeze, [">= 0"])
    s.add_dependency(%q<sass-rails>.freeze, [">= 0"])
    s.add_dependency(%q<coffee-rails>.freeze, [">= 0"])
    s.add_dependency(%q<font-awesome-rails>.freeze, ["~> 4.0"])
    s.add_dependency(%q<truncate_html>.freeze, [">= 0.9.2", "~> 0.9"])
    s.add_dependency(%q<kaminari>.freeze, ["< 2.0", ">= 0.17"])
    s.add_dependency(%q<capybara-accessible>.freeze, [">= 0"])
  end
end
