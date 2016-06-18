# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'app_reputation/version'

Gem::Specification.new do |spec|
  spec.name          = "app_reputation"
  spec.version       = AppReputation::VERSION
  spec.authors       = ["Jing Li"]
  spec.email         = ["thyrlian@gmail.com"]

  spec.summary       = %q{Retrieve application's ratings and reviews.}
  spec.homepage      = "https://github.com/thyrlian/AppReputation"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rest-client", "~> 1.8"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "mocha", "~> 1.1"
  spec.add_development_dependency "coveralls", "~> 0.8"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 0.5"
end
