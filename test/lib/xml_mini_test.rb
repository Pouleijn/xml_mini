require 'test_helper'

describe XmlMini do
  subject { XmlMini }
  let(:options) { {:skip_instruct => true, :builder => Builder::XmlMarkup.new} }

  describe "#rename_key" do
    it { subject.rename_key("my_key").must_equal "my-key" }
    it { subject.rename_key("my_key", dasherize: true).must_equal "my-key" }
    it { subject.rename_key("my_key", dasherize: false).must_equal "my_key" }
    it { subject.rename_key("_id").must_equal "_id" }
    it { subject.rename_key("_my_key").must_equal "_my-key" }
    it { subject.rename_key("id_").must_equal "id_" }
    it { subject.rename_key("my_key_").must_equal "my-key_" }
    it { subject.rename_key("__id").must_equal "__id" }
    it { subject.rename_key("id__").must_equal "id__" }
  end

  describe "#to_tag" do
    it "#to_tag accepts a callable object and passes options with the builder" do
      subject.to_tag(:some_tag,lambda {|o| o[:builder].br }, options)
      assert_xml "<br/>"
    end

    it "#to_tag accepts a callable object and passes options and tag name" do
      subject.to_tag(:tag, lambda {|o, t| o[:builder].b(t) }, options)
      assert_xml "<b>tag</b>"
    end

    it "#to_tag accepts an object responding to #to_xml and passes the options, where :root is key" do
      obj = Object.new
      obj.instance_eval do
        def to_xml(options) options[:builder].yo(options[:root].to_s) end
      end

      subject.to_tag(:tag, obj, options)
      assert_xml "<yo>tag</yo>"
    end

    it "#to_tag accepts arbitrary objects responding to #to_str" do
      subject.to_tag(:b, "Howdy", options)
      assert_xml "<b>Howdy</b>"
    end

    it "#to_tag should dasherize the space when passed a string with spaces as a key" do
      subject.to_tag("New   York", 33, options)
      assert_xml "<New---York type=\"integer\">33</New---York>"
    end

    it "#to_tag should dasherize the space when passed a symbol with spaces as a key" do
      subject.to_tag(:"New   York", 33, options)
      assert_xml "<New---York type=\"integer\">33</New---York>"
    end
  end

  def assert_xml(xml)
    assert_equal xml, options[:builder].target!
  end
end