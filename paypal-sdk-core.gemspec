# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'paypal-sdk-core/version'

Gem::Specification.new do |gem|
  gem.name          = "paypal-sdk-core"
  gem.version       = PayPal::SDK::Core::VERSION
  gem.authors       = ["siddick"]
  gem.email         = ["mebramsha@paypal.com"]
  gem.description   = %q{Core library for PayPal ruby SDK}
  gem.summary       = %q{Core library for PayPal ruby SDK}
  gem.homepage      = "https://www.x.com/"

  gem.files         = Dir['**/*']
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
end
