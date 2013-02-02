# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xml_mini/version'

Gem::Specification.new do |spec|
  spec.authors       = ["Michel Pouleijn", "Erik Michaels-Ober"]
  spec.email         = ['michel@pouleijn.nl', 'sferik@gmail.com']
  spec.description   = %q{Extraction of the XML handling code from ActiveSupport }
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/Pouleijn/xml_mini'

  spec.files         = %w(CONTRIBUTING.md LICENSE.md README.md Rakefile xml_mini.gemspec)
  spec.files        += Dir.glob("lib/**/*.rb")
  spec.files        += Dir.glob("test/**/*")
  spec.test_files    = Dir.glob("test/**/*")

  spec.name          = 'xml_mini'
  spec.require_paths = ['lib']
  spec.version       = XmlMini::VERSION

  spec.add_dependency 'builder', '>= 3.0'
  spec.add_development_dependency 'bundler', '~> 1.0'
end
