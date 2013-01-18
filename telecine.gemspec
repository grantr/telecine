# -*- encoding: utf-8 -*-
require File.expand_path('../lib/telecine/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Grant Rodgers"]
  gem.email         = ["grantr@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = "https://github.com/grantr/telecine"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "telecine"
  gem.require_paths = ["lib"]
  gem.version       = Telecine::VERSION
  gem.platform      = Gem::Platform::RUBY

  gem.add_runtime_dependency "celluloid"
  gem.add_runtime_dependency "celluloid-zmq"
  gem.add_runtime_dependency "red25519"

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'benchmark_suite'
end
