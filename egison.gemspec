$:.push File.expand_path('../lib', __FILE__)
require 'egison/version'

Gem::Specification.new do |s|
  s.name        = 'egison'
  s.version     = Egison::VERSION
  s.authors     = ['Satoshi Egi']
  s.email       = ['egi@egison.org']
  s.homepage    = 'https://github.com/egisatoshi/egison-ruby'
  s.summary     = %q{An Egison pattern matching library}
  s.description = %w{
    A library to access Egison pattern-matching in Ruby.
  }.join(' ')

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f) }
  s.require_paths    = ['lib']
  s.add_development_dependency 'rake'
  s.add_development_dependency 'simplecov'
  s.extra_rdoc_files = ['README.rdoc']
  s.rdoc_options     = ['--main', 'README.rdoc']
end
