# -*- encoding: utf-8 -*-

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "arthropod_waifu2x/version"

Gem::Specification.new do |gem|
  gem.name          = "arthropod_waifu2x"
  gem.version       = ArthropodWaifu2x::VERSION
  gem.authors       = ["Victor Goya"]
  gem.email         = ["goya.victor@gmail.com"]
  gem.description   = "Use Waifu2X remotely Arthropod"
  gem.summary       = "Use Waifu2X remotely Arthropod"

  gem.files         = `git ls-files -z`.split("\x0")
  gem.executables   = %w(arthropod_waifu2x)
  gem.require_paths = ["lib"]
  gem.bindir        = 'bin'

  gem.licenses      = ["MIT"]

  gem.required_ruby_version = "~> 2.0"

  gem.add_dependency 'arthropod', '= 0.0.6'
  gem.add_dependency 'aws-sdk-sqs'
  gem.add_dependency 'fog-aws'
  gem.add_dependency 'foreman'

  gem.add_development_dependency "byebug"
end
