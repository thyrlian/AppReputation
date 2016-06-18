require_relative '../test_helper'

class CountriesTest < Minitest::Test
  def test_parse
    countries = get_countries_from_stub_file(["https://developer.apple.com/", "AB\n", "CD\n", "XX\n", "AB\n"])
    assert_equal(%w(AB CD XX), countries.list)
  end
  
  def test_include_positive
    countries = get_countries_from_stub_file(['AB', 'CD', 'EF', 'JL', 'XX', 'YZ'])
    # test no element
    assert(countries.include?())
    # test one element
    assert(countries.include?('XX'))
    # test more elements
    assert(countries.include?('CD', 'XX'))
    # test different order
    assert(countries.include?('YZ', 'AB', 'XX'))
    # test duplicates
    assert(countries.include?('XX', 'AB', 'XX'))
    # test lowercase and uppercase mixup
    assert(countries.include?('Ab', 'cD', 'EF', 'yz'))
  end
  
  def test_include_negative
    countries = get_countries_from_stub_file(['AB', 'CD', 'EF', 'JL', 'XX', 'YZ'])
    # test one element
    assert(!countries.include?('PQ'))
    # test one abnormal element
    assert(!countries.include?('ABC'))
    # test one positive and one negative
    assert(!countries.include?('AB', 'PQ'))
    # test more elements
    assert(!countries.include?('OO', 'PQ'))
    # test different order
    assert(!countries.include?('YZ', 'AB', 'PQ'))
    # test duplicates
    assert(!countries.include?('AB', 'PQ', 'AB', 'PQ'))
    # test lowercase and uppercase mixup
    assert(!countries.include?('AB', 'pq'))
    # test overloaded elements
    assert(!countries.include?('AB', 'CD', 'EF', 'JL', 'XX', 'YZ', 'BA'))
  end
  
  def get_countries_from_stub_file(content_lines)
    countries = []
    file = MiniTest::Mock.new
    file.expect(:readlines, content_lines)
    File.stub(:join, file) do
      File.stub(:open, '', file) do
        countries = AppReputation::Countries.parse(file)
      end
    end
    countries
  end
end
