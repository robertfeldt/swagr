# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wapp/version'

Gem::Specification.new do |gem|
  gem.name          = "wapp"
  gem.version       = Wapp::VERSION
  gem.authors       = ["Robert Feldt"]
  gem.email         = ["robert.feldt@gmail.com"]
  gem.description   = %q{simple web app framework for creating GUI's to interact with long-running Ruby processes}
  gem.summary       = %q{Simple, barebones web app skeleton creator based on Sinatra, Sass, Slim and Coffeescript. Geared to interfacing with long-running Ruby processes.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('thor')
end
