# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'firebrew/version'

Gem::Specification.new do |spec|
  spec.name          = "firebrew"
  spec.version       = Firebrew::VERSION
  spec.authors       = ["Yuichi Murata"]
  spec.email         = ["mrk21info+rubygems@gmail.com"]
  spec.summary       = %q{Firefox add-ons manager for CUI.}
  spec.description   = %q{Firefox add-ons manager for CUI.}
  spec.homepage      = "https://github.com/mrk21/firebrew"
  spec.license       = "MIT"
  
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  
  spec.add_dependency "activesupport", "~> 4.1"
  spec.add_dependency "activeresource", "~> 4.0"
  spec.add_dependency "activemodel", "~> 4.1"
  spec.add_dependency "inifile", "~> 2.0"
end
