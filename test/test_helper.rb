# encoding: utf-8
ENV["RAILS_ENV"] = "test"

require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'xml_mini'
require 'bigdecimal'
require 'builder'
require 'minitest/autorun'
require 'minitest-spec'

class EmptyTrue
  def empty?() true; end
end

class EmptyFalse
  def empty?() false; end
end
