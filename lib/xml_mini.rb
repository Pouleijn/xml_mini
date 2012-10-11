# encoding: utf-8

require 'base64'
require "xml_mini/version"
require "core_ext/array"
require "core_ext/blank"
require "core_ext/hash"

module XmlMini
  extend Forwardable
  extend self

  # This module decorates files deserialized using Hash.from_xmlmini with
  # the <tt>original_filename</tt> and <tt>content_type</tt> methods.
  module FileLike #:nodoc:
    attr_writer :original_filename, :content_type

    def original_filename
      @original_filename || 'untitled'
    end

    def content_type
      @content_type || 'application/octet-stream'
    end
  end

  DEFAULT_ENCODINGS = {
      "binary" => "base64"
  } unless defined?(DEFAULT_ENCODINGS)

  TYPE_NAMES = {
      "Symbol" => "symbol",
      "Fixnum" => "integer",
      "Bignum" => "integer",
      "BigDecimal" => "decimal",
      "Float" => "float",
      "TrueClass" => "boolean",
      "FalseClass" => "boolean",
      "Date" => "date",
      "DateTime" => "dateTime",
      "Time" => "dateTime",
      "Array" => "array",
      "Hash" => "hash"
  } unless defined?(TYPE_NAMES)

  FORMATTING = {
      "symbol" => Proc.new { |symbol| symbol.to_s },
      "date" => Proc.new { |date| date.to_s },
      "dateTime" => Proc.new { |time| time.xmlschema },
      "binary" => Proc.new { |binary| ::Base64.encode64(binary) },
      "yaml" => Proc.new { |yaml| yaml.to_yaml }
  } unless defined?(FORMATTING)

  # TODO use regexp instead of Date.parse
  unless defined?(PARSING)
    PARSING = {
        "symbol" => Proc.new { |symbol| symbol.to_sym },
        "date" => Proc.new { |date| ::Date.parse(date) },
        "datetime" => Proc.new { |time| Time.xmlschema(time).utc rescue ::DateTime.parse(time).utc },
        "integer" => Proc.new { |integer| integer.to_i },
        "float" => Proc.new { |float| float.to_f },
        "decimal" => Proc.new { |number| BigDecimal(number) },
        "boolean" => Proc.new { |boolean| %w(1 true).include?(boolean.strip) },
        "string" => Proc.new { |string| string.to_s },
        "yaml" => Proc.new { |yaml| YAML::load(yaml) rescue yaml },
        "base64Binary" => Proc.new { |bin| ::Base64.decode64(bin) },
        "binary" => Proc.new { |bin, entity| _parse_binary(bin, entity) },
        "file" => Proc.new { |file, entity| _parse_file(file, entity) }
    }

    PARSING.update(
        "double" => PARSING["float"],
        "dateTime" => PARSING["datetime"]
    )
  end

  attr_reader :backend
  def_delegator :@backend, :parse

  def backend=(name)
    if name.is_a?(Module)
      @backend = name
    else
      require "xml_mini/#{name.downcase}"
      @backend = XmlMini.const_get("XmlMini_#{name}")
    end
  end

  def with_backend(name)
    old_backend, self.backend = backend, name
    yield
  ensure
    self.backend = old_backend
  end

  def to_tag(key, value, options)
    type_name = options.delete(:type)
    merged_options = options.merge(:root => key, :skip_instruct => true)

    if value.is_a?(::Method) || value.is_a?(::Proc)
      if value.arity == 1
        value.call(merged_options)
      else
        value.call(merged_options, key.to_s.singularize)
      end
    elsif value.respond_to?(:to_xml)
      value.to_xml(merged_options)
    else
      type_name ||= TYPE_NAMES[value.class.name]
      type_name ||= value.class.name if value && !value.respond_to?(:to_str)
      type_name = type_name.to_s if type_name
      type_name = "dateTime" if type_name == "datetime"

      key = rename_key(key.to_s, options)

      attributes = options[:skip_types] || type_name.nil? ? {} : {:type => type_name}
      attributes[:nil] = true if value.nil?

      encoding = options[:encoding] || DEFAULT_ENCODINGS[type_name]
      attributes[:encoding] = encoding if encoding

      formatted_value = FORMATTING[type_name] && !value.nil? ?
          FORMATTING[type_name].call(value) : value

      options[:builder].tag!(key, formatted_value, attributes)
    end
  end

  def rename_key(key, options = {})
    dasherize = !options.has_key?(:dasherize) || options[:dasherize]
    key = _dasherize(key) if dasherize
    key
  end

  protected

  def _dasherize(key)
    # $2 must be a non-greedy regex for this to work
    left, middle, right = /\A(_*)(.*?)(_*)\Z/.match(key.strip)[1, 3]
    "#{left}#{middle.tr('_ ', '--')}#{right}"
  end

  def _parse_binary(bin, entity) #:nodoc:
    case entity['encoding']
      when 'base64'
        ::Base64.decode64(bin)
      else
        bin
    end
  end

  def _parse_file(file, entity)
    f = StringIO.new(::Base64.decode64(file))
    f.extend(FileLike)
    f.original_filename = entity['name']
    f.content_type = entity['content_type']
    f
  end
end

XmlMini.backend = 'REXML'
