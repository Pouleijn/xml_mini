require 'test_helper'
#require 'active_support/builder'

module XmlMiniTest
  class RenameKeyTest < MiniTest::Unit::TestCase
    def test_rename_key_dasherizes_by_default
      assert_equal "my-key", XmlMini.rename_key("my_key")
    end

    def test_rename_key_does_nothing_with_dasherize_true
      assert_equal "my-key", XmlMini.rename_key("my_key", :dasherize => true)
    end

    def test_rename_key_does_nothing_with_dasherize_false
      assert_equal "my_key", XmlMini.rename_key("my_key", :dasherize => false)
    end

    def test_rename_key_does_not_dasherize_leading_underscores
      assert_equal "_id", XmlMini.rename_key("_id")
    end

    def test_rename_key_with_leading_underscore_dasherizes_interior_underscores
      assert_equal "_my-key", XmlMini.rename_key("_my_key")
    end

    def test_rename_key_does_not_dasherize_trailing_underscores
      assert_equal "id_", XmlMini.rename_key("id_")
    end

    def test_rename_key_with_trailing_underscore_dasherizes_interior_underscores
      assert_equal "my-key_", XmlMini.rename_key("my_key_")
    end

    def test_rename_key_does_not_dasherize_multiple_leading_underscores
      assert_equal "__id", XmlMini.rename_key("__id")
    end

    def test_rename_key_does_not_dasherize_multiple_trailing_underscores
      assert_equal "id__", XmlMini.rename_key("id__")
    end
  end

  class ToTagTest < MiniTest::Unit::TestCase
    def assert_xml(xml)
      assert_equal xml, @options[:builder].target!
    end

    def setup
      @xml = XmlMini
      @options = {:skip_instruct => true, :builder => Builder::XmlMarkup.new}
    end

    # it "#to_tag accepts a callable object and passes options with the builder" do
    #   @xml.to_tag(:some_tag, lambda {|o| o[:builder].br }, @options)
    #   assert_xml "<br/>"
    # end

    # it "#to_tag accepts a callable object and passes options and tag name" do
    #   @xml.to_tag(:tag, lambda {|o, t| o[:builder].b(t) }, @options)
    #   assert_xml "<b>tag</b>"
    # end

    # it "#to_tag accepts an object responding to #to_xml and passes the options, where :root is key" do
    #   obj = Object.new
    #   obj.instance_eval do
    #     def to_xml(options) options[:builder].yo(options[:root].to_s) end
    #   end

    #   @xml.to_tag(:tag, obj, @options)
    #   assert_xml "<yo>tag</yo>"
    # end

    # it "#to_tag accepts arbitrary objects responding to #to_str" do
    #   @xml.to_tag(:b, "Howdy", @options)
    #   assert_xml "<b>Howdy</b>"
    # end

    # it "#to_tag should dasherize the space when passed a string with spaces as a key" do
    #   @xml.to_tag("New   York", 33, @options)
    #   assert_xml "<New---York type=\"integer\">33</New---York>"
    # end

    # it "#to_tag should dasherize the space when passed a symbol with spaces as a key" do
    #   @xml.to_tag(:"New   York", 33, @options)
    #   assert_xml "<New---York type=\"integer\">33</New---York>"
    # end
    # TODO: test the remaining functions hidden in #to_tag.
  end
end