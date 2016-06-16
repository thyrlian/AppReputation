require_relative '../test_helper'

class IosCountryCodeParserTest < Minitest::Test
  def setup
    @file = MiniTest::Mock.new
  end
  
  def test_parse
    @file.expect(:readlines, ["https://developer.apple.com/", "AB\n", "CD\n", "XX\n"])
    File.stub(:join, @file) do
      File.stub(:open, '', @file) do
        assert_equal(%w(AB CD XX), AppReputation::IosCountryCodeParser.parse(@file))
      end
    end
  end
end
