# -*- encoding: utf-8 -*-
require File.expand_path('../lib/xml_mini/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Michel Pouleijn"]
  gem.email         = ["michel@cttinnovations.com"]
  gem.description   = %q{Extraction of the XML handling code from ActiveSupport }
  gem.summary       = %q{}
  gem.homepage      = "https://github.com/Pouleijn/xml_mini"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "xml_mini"
  gem.require_paths = ["lib"]
  gem.version       = XmlMini::VERSION
  
  gem.add_dependency("builder", ">= 3.0")
  gem.add_development_dependency("rake", ">= 0.9.2")
end
