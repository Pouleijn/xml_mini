# encoding: utf-8

require 'test_helper'
require 'shared/xml_engine'
require 'nokogiri'

describe 'XmlMini_NokogiriSAX' do

  before do
    @default_backend = XmlMini.backend
    @backend = 'NokogiriSAX'
    @xml_error = Nokogiri::XML::SyntaxError
    XmlMini.backend = @backend
  end

  after do
    XmlMini.backend = @default_backend
  end

  it_behaves_like 'An xml engine'
end