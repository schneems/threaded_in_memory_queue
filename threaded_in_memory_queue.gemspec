# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'threaded_in_memory_queue/version'

Gem::Specification.new do |gem|
  gem.name          = "threaded_in_memory_queue"
  gem.version       = ThreadedInMemoryQueue::VERSION
  gem.authors       = ["Richard Schneeman"]
  gem.email         = ["richard.schneeman+rubygems@gmail.com"]
  gem.description   = %q{ Queue stuff in memory }
  gem.summary       = %q{ Memory, Enqueue stuff you will }
  gem.homepage      = "https://github.com/schneems/threaded_in_memory_queue"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
  gem.add_development_dependency "mocha"
end
