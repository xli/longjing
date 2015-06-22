# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'longjing/version'

Gem::Specification.new do |spec|
  spec.name          = "longjing"
  spec.version       = Longjing::VERSION
  spec.authors       = ["Xiao Li"]
  spec.email         = ["swing1979@gmail.com"]

  spec.summary       = %q{Longjing is classical planner.}
  spec.description   = %q{Longjing is classical planner which resolves problems defined by a specific version of PDDL (Planning Domain Definition Language) described in book "Artificial Intelligence: a modern approach".}
  spec.homepage      = "https://github.com/xli/longjing"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
