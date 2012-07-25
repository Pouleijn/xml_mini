# encoding: utf-8

shared_examples_for 'An xml engine' do
  describe 'XmlEngine' do

    it "should thrown exception on expansion attack" do
      assert_raises @xml_error do
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
        Hash.from_xmlmini(attack_xml)
      end
    end unless @xml_error.nil?

    it "should set #{@backend} as backend" do
      XmlMini.backend.must_equal XmlMini.const_get("XmlMini_#{@backend}")
    end

    it "test_blank_returns_empty_hash" do
      XmlMini.parse(nil).must_equal({})
      XmlMini.parse('').must_equal({})
    end

    it "should test file from_xmlmini" do
      hash = Hash.from_xmlmini(<<-eoxml)
      <blog>
        <logo type="file" name="logo.png" content_type="image/png">
        </logo>
      </blog>
      eoxml
      hash.has_key?('blog').must_equal true
      hash['blog'].has_key?('logo').must_equal true

      file = hash['blog']['logo']
      file.original_filename.must_equal 'logo.png'
      file.content_type.must_equal 'image/png'
    end

    it "should test parse from io" do
      io = StringIO.new(<<-eoxml)
    <root>
      good
      <products>
        hello everyone
      </products>
      morning
    </root>
      eoxml
      hash = XmlMini.parse(io)
      hash.has_key?('root').must_equal true
      hash['root'].has_key?('products').must_equal true
    end

    it "should test array type makes an array" do
      must_equal_rexml(<<-eoxml)
      <blog>
        <posts type="array">
          <post>a post</post>
          <post>another post</post>
        </posts>
      </blog>
      eoxml
    end

    it "should have one node document as hash" do
      must_equal_rexml(<<-eoxml)
    <products/>
      eoxml
    end

    it "should test one node with attributes document as hash" do
      must_equal_rexml(<<-eoxml)
    <products foo="bar"/>
      eoxml
    end

    it "should test products node with book node as hash" do
      must_equal_rexml(<<-eoxml)
    <products>
      <book name="awesome" id="12345" />
    </products>
      eoxml
    end

    it "should test products node with two book nodes as hash" do
      must_equal_rexml(<<-eoxml)
    <products>
      <book name="awesome" id="12345" />
      <book name="america" id="67890" />
    </products>
      eoxml
    end

    it "should test single node with content as hash" do
      must_equal_rexml(<<-eoxml)
      <products>
        hello world
      </products>
      eoxml
    end

    it "should test children with children" do
      must_equal_rexml(<<-eoxml)
    <root>
      <products>
        <book name="america" id="67890" />
      </products>
    </root>
      eoxml
    end

    it "should test children with text" do
      must_equal_rexml(<<-eoxml)
    <root>
      <products>
        hello everyone
      </products>
    </root>
      eoxml
    end

    it "should test children with non adjacent text" do
      must_equal_rexml(<<-eoxml)
    <root>
      good
      <products>
        hello everyone
      </products>
      morning
    </root>
      eoxml
    end

    it "should test children with simple cdata" do
      must_equal_rexml(<<-eoxml)
    <root>
      <products>
         <![CDATA[cdatablock]]>
      </products>
    </root>
      eoxml
    end

    it "should test children with multiple cdata" do
      must_equal_rexml(<<-eoxml)
    <root>
      <products>
         <![CDATA[cdatablock1]]><![CDATA[cdatablock2]]>
      </products>
    </root>
      eoxml
    end

    it "should test children with text and cdata" do
      must_equal_rexml(<<-eoxml)
    <root>
      <products>
        hello <![CDATA[cdatablock]]>
        morning
      </products>
    </root>
      eoxml
    end

    it "should test children with blank text" do
      must_equal_rexml(<<-eoxml)
    <root>
      <products>   </products>
    </root>
      eoxml
    end

    it "should test children with blank text and attribute" do
      must_equal_rexml(<<-eoxml)
    <root>
      <products type="file">   </products>
    </root>
      eoxml
    end


    private
    def must_equal_rexml(xml)
      hash = XmlMini.with_backend('REXML') { XmlMini.parse(xml) }
      XmlMini.parse(xml).must_equal hash
    end

  end
end