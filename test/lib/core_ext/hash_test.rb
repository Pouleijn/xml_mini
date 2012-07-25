# encoding: utf-8
require 'test_helper'

class HashToXmlTest < MiniTest::Unit::TestCase
  def setup
    @xml_options = {:root => :person, :skip_instruct => true, :indent => 0}
  end

  def test_one_level
    xml = {:name => "David", :street => "Paulina"}.to_xml(@xml_options)
    assert xml.include?(%(<street>Paulina</street>))
    assert xml.include?(%(<name>David</name>))
  end

  def test_one_level_dasherize_false
    xml = {:name => "David", :street_name => "Paulina"}.to_xml(@xml_options.merge(:dasherize => false))
    assert xml.include?(%(<street_name>Paulina</street_name>))
    assert xml.include?(%(<name>David</name>))
  end

  def test_one_level_dasherize_true
    xml = {:name => "David", :street_name => "Paulina"}.to_xml(@xml_options.merge(:dasherize => true))
    assert xml.include?(%(<street-name>Paulina</street-name>))
    assert xml.include?(%(<name>David</name>))
  end

  def test_one_level_camelize_true
    skip
    xml = {:name => "David", :street_name => "Paulina"}.to_xml(@xml_options.merge(:camelize => true))
    assert xml.include?(%(<StreetName>Paulina</StreetName>))
    assert xml.include?(%(<Name>David</Name>))
  end

  def test_one_level_camelize_lower
    skip
    xml = {:name => "David", :street_name => "Paulina"}.to_xml(@xml_options.merge(:camelize => :lower))
    assert xml.include?(%(<streetName>Paulina</streetName>))
    assert xml.include?(%(<name>David</name>))
  end

  def test_one_level_with_types
    xml = {:name => "David", :street => "Paulina", :age => 26, :age_in_millis => 820497600000, :moved_on => Date.new(2005, 11, 15), :resident => :yes}.to_xml(@xml_options)
    assert xml.include?(%(<street>Paulina</street>))
    assert xml.include?(%(<name>David</name>))
    assert xml.include?(%(<age type="integer">26</age>))
    assert xml.include?(%(<age-in-millis type="integer">820497600000</age-in-millis>))
    assert xml.include?(%(<moved-on type="date">2005-11-15</moved-on>))
    assert xml.include?(%(<resident type="symbol">yes</resident>))
  end

  def test_one_level_with_nils
    xml = {:name => "David", :street => "Paulina", :age => nil}.to_xml(@xml_options)
    assert xml.include?(%(<street>Paulina</street>))
    assert xml.include?(%(<name>David</name>))
    assert xml.include?(%(<age nil="true"></age>))
  end

  def test_one_level_with_skipping_types
    xml = {:name => "David", :street => "Paulina", :age => nil}.to_xml(@xml_options.merge(:skip_types => true))
    assert xml.include?(%(<street>Paulina</street>))
    assert xml.include?(%(<name>David</name>))
    assert xml.include?(%(<age nil="true"></age>))
  end

  def test_one_level_with_yielding
    xml = {:name => "David", :street => "Paulina"}.to_xml(@xml_options) do |x|
      x.creator("Rails")
    end

    assert xml.include?(%(<street>Paulina</street>))
    assert xml.include?(%(<name>David</name>))
    assert xml.include?(%(<creator>Rails</creator>))
  end

  def test_two_levels
    xml = {:name => "David", :address => {:street => "Paulina"}}.to_xml(@xml_options)
    assert xml.include?(%(<address><street>Paulina</street></address>))
    assert xml.include?(%(<name>David</name>))
  end

  def test_two_levels_with_second_level_overriding_to_xml
    xml = {:name => "David", :address => {:street => "Paulina"}, :child => IWriteMyOwnXML.new}.to_xml(@xml_options)
    assert xml.include?(%(<address><street>Paulina</street></address>))
    assert xml.include?(%(<level_one><second_level>content</second_level></level_one>))
  end

  def test_two_levels_with_array
    skip
    xml = {"name" => "David", "addresses" => [{"street" => "Paulina"}, {"street" => "Evergreen"}]}.to_xml(@xml_options)
    assert xml.include?(%(<addresses type="array"><address>))
    assert xml.include?(%(<address><street>Paulina</street></address>))
    assert xml.include?(%(<address><street>Evergreen</street></address>))
    assert xml.include?(%(<name>David</name>))
  end

  def test_three_levels_with_array
    skip
    xml = {:name => "David", :addresses => [{:streets => [{:name => "Paulina"}, {:name => "Paulina"}]}]}.to_xml(@xml_options)
    assert xml.include?(%(<addresses type="array"><address><streets type="array"><street><name>))
  end

  def test_timezoned_attributes
    xml = {
        :created_at => Time.utc(1999, 2, 2),
        :local_created_at => Time.utc(1999, 2, 2).in_time_zone('Eastern Time (US & Canada)')
    }.to_xml(@xml_options)
    assert_match %r{<created-at type=\"datetime\">1999-02-02T00:00:00Z</created-at>}, xml
    assert_match %r{<local-created-at type=\"datetime\">1999-02-01T19:00:00-05:00</local-created-at>}, xml
  end

  def test_multiple_records_from_minixml_with_attributes_other_than_type_ignores_them_without_exploding
    topics_xml = <<-EOT
      <topics type="array" page="1" page-count="1000" per-page="2">
        <topic>
          <title>The First Topic</title>
          <author-name>David</author-name>
          <id type="integer">1</id>
          <approved type="boolean">false</approved>
          <replies-count type="integer">0</replies-count>
          <replies-close-in type="integer">2592000000</replies-close-in>
          <written-on type="date">2003-07-16</written-on>
          <viewed-at type="datetime">2003-07-16T09:28:00+0000</viewed-at>
          <content>Have a nice day</content>
          <author-email-address>david@loudthinking.com</author-email-address>
          <parent-id nil="true"></parent-id>
        </topic>
        <topic>
          <title>The Second Topic</title>
          <author-name>Jason</author-name>
          <id type="integer">1</id>
          <approved type="boolean">false</approved>
          <replies-count type="integer">0</replies-count>
          <replies-close-in type="integer">2592000000</replies-close-in>
          <written-on type="date">2003-07-16</written-on>
          <viewed-at type="datetime">2003-07-16T09:28:00+0000</viewed-at>
          <content>Have a nice day</content>
          <author-email-address>david@loudthinking.com</author-email-address>
          <parent-id></parent-id>
        </topic>
      </topics>
    EOT

    expected_topic_hash = {
        "title" => "The First Topic",
        "author_name" => "David",
        "id" => 1,
        "approved" => false,
        "replies_count" => 0,
        "replies_close_in" => 2592000000,
        "written_on" => Date.new(2003, 7, 16),
        "viewed_at" => Time.utc(2003, 7, 16, 9, 28),
        "content" => "Have a nice day",
        "author_email_address" => "david@loudthinking.com",
        "parent_id" => nil
    }

    assert_equal expected_topic_hash, Hash.from_minixml(topics_xml)["topics"].first
  end

  def test_single_record_from_minixml
    topic_xml = <<-EOT
      <topic>
        <title>The First Topic</title>
        <author-name>David</author-name>
        <id type="integer">1</id>
        <approved type="boolean"> true </approved>
        <replies-count type="integer">0</replies-count>
        <replies-close-in type="integer">2592000000</replies-close-in>
        <written-on type="date">2003-07-16</written-on>
        <viewed-at type="datetime">2003-07-16T09:28:00+0000</viewed-at>
        <content type="yaml">--- \n1: should be an integer\n:message: Have a nice day\narray: \n- should-have-dashes: true\n  should_have_underscores: true\n</content>
        <author-email-address>david@loudthinking.com</author-email-address>
        <parent-id></parent-id>
        <ad-revenue type="decimal">1.5</ad-revenue>
        <optimum-viewing-angle type="float">135</optimum-viewing-angle>
        <resident type="symbol">yes</resident>
      </topic>
    EOT

    expected_topic_hash = {
        "title" => "The First Topic",
        "author_name" => "David",
        "id" => 1,
        "approved" => true,
        "replies_count" => 0,
        "replies_close_in" => 2592000000,
        "written_on" => Date.new(2003, 7, 16),
        "viewed_at" => Time.utc(2003, 7, 16, 9, 28),
        "content" => {"message" => "Have a nice day", 1 => "should be an integer", "array" => [{"should-have-dashes" => true, "should_have_underscores" => true}]},
        "author_email_address" => "david@loudthinking.com",
        "parent_id" => nil,
        "ad_revenue" => BigDecimal("1.50"),
        "optimum_viewing_angle" => 135.0,
        "resident" => "yes"
    }

    assert_equal expected_topic_hash, Hash.from_minixml(topic_xml)["topic"]
  end

  def test_single_record_from_minixml_with_nil_values
    topic_xml = <<-EOT
      <topic>
        <title></title>
        <id type="integer"></id>
        <approved type="boolean"></approved>
        <written-on type="date"></written-on>
        <viewed-at type="datetime"></viewed-at>
        <content type="yaml"></content>
        <parent-id></parent-id>
      </topic>
    EOT

    expected_topic_hash = {
        "title" => nil,
        "id" => nil,
        "approved" => nil,
        "written_on" => nil,
        "viewed_at" => nil,
        "content" => nil,
        "parent_id" => nil
    }

    assert_equal expected_topic_hash, Hash.from_minixml(topic_xml)["topic"]
  end

  def test_multiple_records_from_minixml
    topics_xml = <<-EOT
      <topics type="array">
        <topic>
          <title>The First Topic</title>
          <author-name>David</author-name>
          <id type="integer">1</id>
          <approved type="boolean">false</approved>
          <replies-count type="integer">0</replies-count>
          <replies-close-in type="integer">2592000000</replies-close-in>
          <written-on type="date">2003-07-16</written-on>
          <viewed-at type="datetime">2003-07-16T09:28:00+0000</viewed-at>
          <content>Have a nice day</content>
          <author-email-address>david@loudthinking.com</author-email-address>
          <parent-id nil="true"></parent-id>
        </topic>
        <topic>
          <title>The Second Topic</title>
          <author-name>Jason</author-name>
          <id type="integer">1</id>
          <approved type="boolean">false</approved>
          <replies-count type="integer">0</replies-count>
          <replies-close-in type="integer">2592000000</replies-close-in>
          <written-on type="date">2003-07-16</written-on>
          <viewed-at type="datetime">2003-07-16T09:28:00+0000</viewed-at>
          <content>Have a nice day</content>
          <author-email-address>david@loudthinking.com</author-email-address>
          <parent-id></parent-id>
        </topic>
      </topics>
    EOT

    expected_topic_hash = {
        "title" => "The First Topic",
        "author_name" => "David",
        "id" => 1,
        "approved" => false,
        "replies_count" => 0,
        "replies_close_in" => 2592000000,
        "written_on" => Date.new(2003, 7, 16),
        "viewed_at" => Time.utc(2003, 7, 16, 9, 28),
        "content" => "Have a nice day",
        "author_email_address" => "david@loudthinking.com",
        "parent_id" => nil
    }

    assert_equal expected_topic_hash, Hash.from_minixml(topics_xml)["topics"].first
  end

  def test_single_record_from_minixml_with_attributes_other_than_type
    topic_xml = <<-EOT
    <rsp stat="ok">
      <photos page="1" pages="1" perpage="100" total="16">
        <photo id="175756086" owner="55569174@N00" secret="0279bf37a1" server="76" title="Colored Pencil PhotoBooth Fun" ispublic="1" isfriend="0" isfamily="0"/>
      </photos>
    </rsp>
    EOT

    expected_topic_hash = {
        "id" => "175756086",
        "owner" => "55569174@N00",
        "secret" => "0279bf37a1",
        "server" => "76",
        "title" => "Colored Pencil PhotoBooth Fun",
        "ispublic" => "1",
        "isfriend" => "0",
        "isfamily" => "0",
    }

    assert_equal expected_topic_hash, Hash.from_minixml(topic_xml)["rsp"]["photos"]["photo"]
  end

  def test_all_caps_key_from_minixml
    test_xml = <<-EOT
      <ABC3XYZ>
        <TEST>Lorem Ipsum</TEST>
      </ABC3XYZ>
    EOT

    expected_hash = {
        "ABC3XYZ" => {
            "TEST" => "Lorem Ipsum"
        }
    }

    assert_equal expected_hash, Hash.from_minixml(test_xml)
  end

  def test_empty_array_from_minixml
    blog_xml = <<-XML
      <blog>
        <posts type="array"></posts>
      </blog>
    XML
    expected_blog_hash = {"blog" => {"posts" => []}}
    assert_equal expected_blog_hash, Hash.from_minixml(blog_xml)
  end

  def test_empty_array_with_whitespace_from_minixml
    blog_xml = <<-XML
      <blog>
        <posts type="array">
        </posts>
      </blog>
    XML
    expected_blog_hash = {"blog" => {"posts" => []}}
    assert_equal expected_blog_hash, Hash.from_minixml(blog_xml)
  end

  def test_array_with_one_entry_from_minixml
    blog_xml = <<-XML
      <blog>
        <posts type="array">
          <post>a post</post>
        </posts>
      </blog>
    XML
    expected_blog_hash = {"blog" => {"posts" => ["a post"]}}
    assert_equal expected_blog_hash, Hash.from_minixml(blog_xml)
  end

  def test_array_with_multiple_entries_from_minixml
    blog_xml = <<-XML
      <blog>
        <posts type="array">
          <post>a post</post>
          <post>another post</post>
        </posts>
      </blog>
    XML
    expected_blog_hash = {"blog" => {"posts" => ["a post", "another post"]}}
    assert_equal expected_blog_hash, Hash.from_minixml(blog_xml)
  end

  def test_file_from_minixml
    blog_xml = <<-XML
      <blog>
        <logo type="file" name="logo.png" content_type="image/png">
        </logo>
      </blog>
    XML
    hash = Hash.from_minixml(blog_xml)
    assert hash.has_key?('blog')
    assert hash['blog'].has_key?('logo')

    file = hash['blog']['logo']
    assert_equal 'logo.png', file.original_filename
    assert_equal 'image/png', file.content_type
  end

  def test_file_from_minixml_with_defaults
    blog_xml = <<-XML
      <blog>
        <logo type="file">
        </logo>
      </blog>
    XML
    file = Hash.from_minixml(blog_xml)['blog']['logo']
    assert_equal 'untitled', file.original_filename
    assert_equal 'application/octet-stream', file.content_type
  end

  def test_tag_with_attrs_and_whitespace
    xml = <<-XML
      <blog name="bacon is the best">
      </blog>
    XML
    hash = Hash.from_minixml(xml)
    assert_equal "bacon is the best", hash['blog']['name']
  end

  def test_empty_cdata_from_minixml
    xml = "<data><![CDATA[]]></data>"

    assert_equal "", Hash.from_minixml(xml)["data"]
  end

  def test_xsd_like_types_from_minixml
    bacon_xml = <<-EOT
    <bacon>
      <weight type="double">0.5</weight>
      <price type="decimal">12.50</price>
      <chunky type="boolean"> 1 </chunky>
      <expires-at type="dateTime">2007-12-25T12:34:56+0000</expires-at>
      <notes type="string"></notes>
      <illustration type="base64Binary">YmFiZS5wbmc=</illustration>
      <caption type="binary" encoding="base64">VGhhdCdsbCBkbywgcGlnLg==</caption>
    </bacon>
    EOT

    expected_bacon_hash = {
        "weight" => 0.5,
        "chunky" => true,
        "price" => BigDecimal("12.50"),
        "expires_at" => Time.utc(2007, 12, 25, 12, 34, 56),
        "notes" => "",
        "illustration" => "babe.png",
        "caption" => "That'll do, pig."
    }

    assert_equal expected_bacon_hash, Hash.from_minixml(bacon_xml)["bacon"]
  end

  def test_type_trickles_through_when_unknown
    product_xml = <<-EOT
    <product>
      <weight type="double">0.5</weight>
      <image type="ProductImage"><filename>image.gif</filename></image>

    </product>
    EOT

    expected_product_hash = {
        "weight" => 0.5,
        "image" => {'type' => 'ProductImage', 'filename' => 'image.gif'},
    }

    assert_equal expected_product_hash, Hash.from_minixml(product_xml)["product"]
  end

  def test_should_use_default_value_for_unknown_key
    hash_wia = HashWithIndifferentAccess.new(3)
    assert_equal 3, hash_wia[:new_key]
  end

  def test_should_use_default_value_if_no_key_is_supplied
    hash_wia = HashWithIndifferentAccess.new(3)
    assert_equal 3, hash_wia.default
  end

  def test_should_nil_if_no_default_value_is_supplied
    hash_wia = HashWithIndifferentAccess.new
    assert_nil hash_wia.default
  end

  def test_should_return_dup_for_with_indifferent_access
    hash_wia = HashWithIndifferentAccess.new
    assert_equal hash_wia, hash_wia.with_indifferent_access
    assert_not_same hash_wia, hash_wia.with_indifferent_access
  end

  def test_should_copy_the_default_value_when_converting_to_hash_with_indifferent_access
    hash = Hash.new(3)
    hash_wia = hash.with_indifferent_access
    assert_equal 3, hash_wia.default
  end

  # The XML builder seems to fail miserably when trying to tag something
  # with the same name as a Kernel method (throw, test, loop, select ...)
  def test_kernel_method_names_to_xml
    hash = {:throw => {:ball => 'red'}}
    expected = '<person><throw><ball>red</ball></throw></person>'

    assert_nothing_raised do
      assert_equal expected, hash.to_xml(@xml_options)
    end
  end

  def test_empty_string_works_for_typecast_xml_value
    assert_nothing_raised do
      Hash.__send__(:typecast_xml_value, "")
    end
  end

  def test_escaping_to_xml
    hash = {
        "bare_string" => 'First & Last Name',
        "pre_escaped_string" => 'First &amp; Last Name'
    }

    expected_xml = '<person><bare-string>First &amp; Last Name</bare-string><pre-escaped-string>First &amp;amp; Last Name</pre-escaped-string></person>'
    assert_equal expected_xml, hash.to_xml(@xml_options)
  end

  def test_unescaping_from_minixml
    xml_string = '<person><bare-string>First &amp; Last Name</bare-string><pre-escaped-string>First &amp;amp; Last Name</pre-escaped-string></person>'
    expected_hash = {
        "bare_string" => 'First & Last Name',
        "pre_escaped_string" => 'First &amp; Last Name'
    }
    assert_equal expected_hash, Hash.from_minixml(xml_string)['person']
  end

  def test_roundtrip_to_xml_from_minixml
    hash = {
        "bare_string" => 'First & Last Name',
        "pre_escaped_string" => 'First &amp; Last Name'
    }

    assert_equal hash, Hash.from_minixml(hash.to_xml(@xml_options))['person']
  end

  def test_datetime_xml_type_with_utc_time
    alert_xml = <<-XML
      <alert>
        <alert_at type="datetime">2008-02-10T15:30:45Z</alert_at>
      </alert>
    XML
    alert_at = Hash.from_minixml(alert_xml)['alert']['alert_at']
    assert alert_at.utc?
    assert_equal Time.utc(2008, 2, 10, 15, 30, 45), alert_at
  end

  def test_datetime_xml_type_with_non_utc_time
    alert_xml = <<-XML
      <alert>
        <alert_at type="datetime">2008-02-10T10:30:45-05:00</alert_at>
      </alert>
    XML
    alert_at = Hash.from_minixml(alert_xml)['alert']['alert_at']
    assert_equal Time.utc(2008, 2, 10, 15, 30, 45), alert_at
  end

  def test_datetime_xml_type_with_far_future_date
    alert_xml = <<-XML
      <alert>
        <alert_at type="datetime">2050-02-10T15:30:45Z</alert_at>
      </alert>
    XML
    alert_at = Hash.from_minixml(alert_xml)['alert']['alert_at']
    assert alert_at.utc?
    assert_equal 2050, alert_at.year
    assert_equal 2, alert_at.month
    assert_equal 10, alert_at.day
    assert_equal 15, alert_at.hour
    assert_equal 30, alert_at.min
    assert_equal 45, alert_at.sec
  end

  def test_to_xml_dups_options
    options = {:skip_instruct => true}
    {}.to_xml(options)
    # :builder, etc, shouldn't be added to options
    assert_equal({:skip_instruct => true}, options)
  end

  def test_expansion_count_is_limited
    expected =
        case XmlMini.backend.name
          when 'XmlMini_REXML';
            RuntimeError
          when 'XmlMini_Nokogiri';
            Nokogiri::XML::SyntaxError
          when 'XmlMini_NokogiriSAX';
            RuntimeError
          when 'XmlMini_LibXML';
            LibXML::XML::Error
          when 'XmlMini_LibXMLSAX';
            LibXML::XML::Error
        end

    assert_raise expected do
      attack_xml = <<-EOT
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE member [
        <!ENTITY a "&b;&b;&b;&b;&b;&b;&b;&b;&b;&b;">
        <!ENTITY b "&c;&c;&c;&c;&c;&c;&c;&c;&c;&c;">
        <!ENTITY c "&d;&d;&d;&d;&d;&d;&d;&d;&d;&d;">
        <!ENTITY d "&e;&e;&e;&e;&e;&e;&e;&e;&e;&e;">
        <!ENTITY e "&f;&f;&f;&f;&f;&f;&f;&f;&f;&f;">
        <!ENTITY f "&g;&g;&g;&g;&g;&g;&g;&g;&g;&g;">
        <!ENTITY g "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx">
      ]>
      <member>
      &a;
      </member>
      EOT
      Hash.from_minixml(attack_xml)
    end
  end
end