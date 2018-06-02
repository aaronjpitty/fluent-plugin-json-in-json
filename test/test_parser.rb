require_relative 'helper'
require 'fluent/test/driver/parser'
require 'fluent/plugin/parser_json_in_json'

class JsonInJsonParserTest < ::Test::Unit::TestCase
  def setup
    Fluent::Test.setup
    @parser = Fluent::Test::Driver::Parser.new(Fluent::Plugin::JSONInJSONParser)
  end

  def test_parse()
    @parser.configure({})
    @parser.instance.parse('{"time":1362020400,"host":"192.168.0.1","size":777,"method":"PUT","log_json":" {\\"field1\\":\\"field1 value\\",\\"field2\\":40}"}') { |time, record|
      assert_equal(event_time('2013-02-28 12:00:00 +0900').to_i, time)
      assert_equal({
                     'host'   => '192.168.0.1',
                     'size'   => 777,
                     'method' => 'PUT',
                     'field1' => 'field1 value',
                     'field2' => 40
                   }, record)
    }
    @parser.instance.parse('{"time":1362020400,"host":"192.168.0.1","size":777,"method":"PUT","log_json":"{\\"field1\\":"}') { |time, record|
      assert_equal(event_time('2013-02-28 12:00:00 +0900').to_i, time)
      assert_equal({
                     'host'   => '192.168.0.1',
                     'size'   => 777,
                     'method' => 'PUT',
                     'log_json' => '{"field1":'
                   }, record)
    }
    @parser.instance.parse('{"time":1362020400,"host":"192.168.0.1","size":777,"method":"PUT","log_json":"[\\"val1\\",\\"val2\\"]"') { |time, record|
      assert_equal(event_time('2013-02-28 12:00:00 +0900').to_i, time)
      assert_equal({
                     'host'   => '192.168.0.1',
                     'size'   => 777,
                     'method' => 'PUT',
                     'log_json' => ['val1', 'val2']
                   }, record)
    }

  end
end
