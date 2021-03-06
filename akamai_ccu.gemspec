# coding: utf-8
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "akamai_ccu/version"

Gem::Specification.new do |s|
  s.name = "akamai_ccu"
  s.version = AkamaiCCU::VERSION
  s.authors = ["costajob"]
  s.email = ["costajob@gmail.com"]
  s.summary = "Minimal wrapper around Akamai CCU V3 APIs"
  s.homepage = "https://github.com/costajob/akamai_ccu"
  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|test|s|features)/}) }
  s.bindir = "bin"
  s.executables = %w[ccu_invalidate ccu_delete]
  s.require_paths = ["lib"]
  s.license = "MIT"
  s.required_ruby_version = ">= 2.1.2"

  s.add_development_dependency "bundler", "~> 1.15"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "benchmark-ips", "~> 2.7"
end
