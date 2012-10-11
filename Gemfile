source 'https://rubygems.org'

# Specify your gem's dependencies in xml_mini.gemspec
gemspec

gem 'builder'

group :development, :test do
  gem 'rake'
  gem 'minitest'
  gem 'minitest-spec'
  gem 'libxml-ruby'
  gem 'nokogiri'
end

group :test do
  gem 'guard'
  gem 'guard-minitest', github: 'mpouleijn/guard-minitest'
  gem 'guard-bundler'
  gem 'terminal-notifier-guard'
  gem 'simplecov', require: false
end
