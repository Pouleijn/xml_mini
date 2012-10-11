# encoding: utf-8

require 'test_helper'
require 'shared/xml_engine'
require 'libxml'

describe 'XmlMini_LibXML' do
  before do
    @default_backend = XmlMini.backend
    @backend = 'LibXML'
    @xml_error = LibXML::XML::Error
    XmlMini.backend = @backend

    @xml_error.set_handler(&lambda { |error|}) #silence libxml, exceptions will do
  end

  after do
    XmlMini.backend = @default_backend
  end

  it_behaves_like 'An xml engine'
end
