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
    refute(countries.include?('PQ'))
    # test one abnormal element
    refute(countries.include?('ABC'))
    # test one positive and one negative
    refute(countries.include?('AB', 'PQ'))
    # test more elements
    refute(countries.include?('OO', 'PQ'))
    # test different order
    refute(countries.include?('YZ', 'AB', 'PQ'))
    # test duplicates
    refute(countries.include?('AB', 'PQ', 'AB', 'PQ'))
    # test lowercase and uppercase mixup
    refute(countries.include?('AB', 'pq'))
    # test overloaded elements
    refute(countries.include?('AB', 'CD', 'EF', 'JL', 'XX', 'YZ', 'BA'))
  end
  
  def test_list_unsupported_countries
    countries = get_countries_from_stub_file(['AB', 'CD', 'EF', 'JL', 'XX', 'YZ'])
    assert_empty(countries.list_unsupported_countries())
    assert_empty(countries.list_unsupported_countries('AB', 'YZ'))
    assert_equal(['ZZ'], countries.list_unsupported_countries('ZZ', 'AB', 'ZZ'))
    assert_equal(['OO', 'PQ'], countries.list_unsupported_countries('oo', 'AB', 'PQ'))
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
