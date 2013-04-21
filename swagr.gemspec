# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'swagr/version'

Gem::Specification.new do |gem|
  gem.name          = "swagr"
  gem.version       = Swagr::VERSION
  gem.authors       = ["Robert Feldt"]
  gem.email         = ["robert.feldt@gmail.com"]
  gem.description   = %q{simple web app gui framework for ruby}
  gem.summary       = %q{Simple, barebones web app gui framework for Ruby programs/processes. Based on Sinatra, Sass, Slim, Coffeescript and d3.js. Geared to interfacing with long-running Ruby processes.}
  gem.homepage      = "https://github.com/robertfeldt/swagr"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('sinatra')
  gem.add_dependency('thor')
  gem.add_dependency('slim')
  gem.add_dependency('coffee-script')
  gem.add_dependency('json')
  gem.add_dependency('feldtruby')

end
