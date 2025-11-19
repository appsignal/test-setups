# -*- encoding: utf-8 -*-
# stub: solid_queue 0.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "solid_queue".freeze
  s.version = "0.1.2".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "homepage_uri" => "http://github.com/basecamp/solid_queue", "source_code_uri" => "http://github.com/basecamp/solid_queue" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Rosa Gutierrez".freeze]
  s.date = "2023-12-21"
  s.description = "Database-backed Active Job backend.".freeze
  s.email = ["rosa@37signals.com".freeze]
  s.homepage = "http://github.com/basecamp/solid_queue".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.5.6".freeze
  s.summary = "Database-backed Active Job backend.".freeze

  s.installed_by_version = "3.5.6".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rails>.freeze, [">= 7.0.3.1".freeze])
  s.add_development_dependency(%q<debug>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<mocha>.freeze, [">= 0".freeze])
end
