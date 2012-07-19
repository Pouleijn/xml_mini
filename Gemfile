source 'https://rubygems.org'

# Specify your gem's dependencies in xml_mini.gemspec
gemspec

gem 'bundler'
gem 'rake'


group :development, :test do
  gem 'minitest' 
  gem 'libxml-ruby'
  gem 'nokogiri'
end
  
group :test do
  gem 'guard'
  gem 'guard-minitest', github: 'mpouleijn/guard-minitest'
  gem 'guard-bundler'
end
