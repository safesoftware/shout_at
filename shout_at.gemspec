# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shout_at/version'

Gem::Specification.new do |spec|
  spec.name          = "shout_at"
  spec.version       = ShoutAt::VERSION
  spec.authors       = ["Claude Vessaz"]
  spec.email         = ["claude.vessaz@safe.com"]

  spec.summary       = %q{DevOps and support notification library for Rails}
  spec.homepage      = "https://www.safe.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "pagerduty"
  spec.add_runtime_dependency "airbrake-ruby", '~> 1.0'
  spec.add_runtime_dependency "slack-notifier"
  spec.add_runtime_dependency "rails", ">= 4.0"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "gem-release"
end
