require 'stringio'
require 'xml_mini/node_hash'

module XmlMini_Nokogiri
  extend self

# Parse an XML Document string or IO into a simple hash using libxml / nokogiri.
# data::
#   XML Document string or IO to parse
  def parse(data)
    if !data.respond_to?(:read)
      data = StringIO.new(data || '')
    end

    char = data.getc
    if char.nil?
      {}
    else
      data.ungetc(char)
      doc = Nokogiri::XML(data)
      raise doc.errors.first if doc.errors.length > 0
      doc.to_hash
    end
  end

  module Conversions #:nodoc:
    module Document #:nodoc:
      def to_hash
        root.to_hash
      end
    end

    module Node
      include NodeHash

      # Convert XML document to hash
      #
      # hash::
      #   Hash to merge the converted element into.
      def to_hash(hash={})
        node_hash = {}

        # Insert node hash into parent hash correctly.
        insert_node_hash_into_parent(hash, name, node_hash)

        # Handle child elements
        children.each do |child|
          handle_child_element(child, node_hash)
        end

        # Remove content node if it is empty and there are child tags
        remove_blank_content_node node_hash

        # Handle attributes
        attribute_nodes.each { |a| node_hash[a.node_name] = a.value }

        hash
      end
    end
  end

  Nokogiri::XML::Document.send(:include, Conversions::Document)
  Nokogiri::XML::Node.send(:include, Conversions::Node)
end
