# encoding: utf-8

require 'simplecov'
SimpleCov.start do
  add_filter "/test/"

  command_name 'Unit Tests'
end if ENV["COVERAGE"]

ENV["RAILS_ENV"] = "test"

gem 'minitest'
require 'minitest/autorun'
require 'minitest-spec'
require 'xml_mini'
require 'bigdecimal'

class EmptyTrue
  def empty?() true; end
end

class EmptyFalse
  def empty?() false; end
end