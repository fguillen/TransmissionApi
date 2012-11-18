# -*- encoding: utf-8 -*-
require File.expand_path('../lib/transmission_api/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Fernando Guillen"]
  gem.email         = ["fguillen.mail@gmail.com"]
  gem.description   = "small ruby wrapper for the Transmission RPC API"
  gem.summary       = "small ruby wrapper for the Transmission RPC API"
  gem.homepage      = "https://github.com/fguillen/TransmissionApi"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "transmission_api"
  gem.require_paths = ["lib"]
  gem.version       = TransmissionApi::VERSION

  gem.add_dependency "httparty", "0.9.0"

  gem.add_development_dependency "mocha", "0.13.0"
end
