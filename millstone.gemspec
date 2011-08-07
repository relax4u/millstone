# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'millstone'
  s.version     = '0.1.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Yoshikazu Ozawa']
  s.email       = ['yoshikazu.ozawa@gmail.com']
  s.homepage    = 'https://github.com/relax4u/millstone'
  s.summary     = 'ActiveRecord plugin which allows you to hide without actually deleting them for Rails3.'
  s.description = 'Millstone is ActiveRecord plugin which allows you to hide without actually deleting them for Rails3.'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.require_paths = ['lib']

  s.licenses = ['MIT']

  s.add_dependency 'rails', ['>= 3.0.0']
end
