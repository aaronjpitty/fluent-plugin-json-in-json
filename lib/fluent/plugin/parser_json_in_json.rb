require 'fluent/parser'
require 'yajl'

module Fluent
  module Plugin
    class JSONInJSONParser < Parser
      Plugin.register_parser('json_in_json', self)

      config_set_default :time_key, 'timestamp'
      config_set_default :time_type, :float

      def configure(conf)
        if conf.has_key?('time_format')
          conf['time_type'] ||= 'string'
        end

        super
      end

      def parse(text)
        record = Yajl.load(text)

        values = Hash.new

        record.each do |k, v|
          if v.is_a?(String) && /^\s*(\{|\[)/ =~ v
            begin
              deserialized = Yajl.load(v)
              if deserialized.is_a?(Hash)
                values.merge!(deserialized)
                record.delete k
              elsif deserialized.is_a?(Array)
                values[k] = deserialized
              end
            rescue Yajl::ParseError
              # continue if failed to parse record
            end
          end
        end
        record.merge!(values)

        timestamp, record = convert_values(parse_time(record), record)

        yield timestamp, record
      rescue Yajl::ParseError
        yield nil, nil
      end
    end
  end
end
