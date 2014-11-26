# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fidelity/version'

Gem::Specification.new do |spec|
  spec.name          = "fidelity"
  spec.version       = Fidelity::VERSION
  spec.authors       = ["phil"]
  spec.email         = ["phil@branch14.org"]
  spec.description   = %q{Fidelity will run audio strategies comprised of a plethora of other audio tools}
  spec.summary       = %q{orchestrates audio processing tools}
  spec.homepage      = "http://github.com/munen/fidelity"
  spec.license       = "proprietary"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "wrong"

  spec.add_dependency 'term-ansicolor'
  spec.add_dependency 'fileutils_logger'
  spec.add_dependency 'systemu'
  spec.add_dependency 'auphonic'
end
