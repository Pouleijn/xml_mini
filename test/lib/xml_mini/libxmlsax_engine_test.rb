# encoding: utf-8

require 'test_helper'
require 'shared/xml_engine'
require 'libxml'

describe 'XmlMini_LibXMLSAX' do

  before do
    @default_backend = XmlMini.backend
    @backend = 'LibXMLSAX'
    @xml_error = RuntimeError
    XmlMini.backend = @backend
  end

  after do
    XmlMini.backend = @default_backend
  end

  it_behaves_like 'An xml engine'
end