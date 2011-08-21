# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'millstone/version'

Gem::Specification.new do |s|
  s.name        = 'millstone'
  s.version     = Millstone::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Yoshikazu Ozawa']
  s.email       = ['yoshikazu.ozawa@gmail.com']
  s.homepage    = 'https://github.com/relax4u/millstone'
  s.summary     = 'ActiveRecord plugin which allows you to hide without actually deleting them for Rails3.'
  s.description = 'ActiveRecord plugin which allows you to hide without actually deleting them for Rails3. Millstone is extending ActiveRecord::Relation'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.require_paths = ['lib']

  s.licenses = ['MIT']

  s.add_dependency 'rails', ['>= 3.0.3']
  s.add_development_dependency 'bundler', ['>= 1.0.0']
  s.add_development_dependency 'sqlite3', ['>= 0']
  s.add_development_dependency 'rspec', ['>= 2.0.0']
  s.add_development_dependency 'rspec-rails', ['>= 2.0.0']
  s.add_development_dependency 'delorean', ['>= 0']
end
