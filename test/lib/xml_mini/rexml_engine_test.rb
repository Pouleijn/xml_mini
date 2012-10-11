# encoding: utf-8

require 'test_helper'
require 'shared/xml_engine'
require 'xml_mini/rexml'

describe 'XmlMini_REXML' do

  before do
    @default_backend = XmlMini.backend
    @backend = 'REXML'
    @xml_error = RuntimeError
    XmlMini.backend = @backend
  end

  it_behaves_like 'An xml engine'
end
