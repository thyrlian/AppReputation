require 'test_helper'
require_relative '../util/countries_test_helper'

class IosRatingsBuilderTest < Minitest::Test
  include CountriesTestHelper
  
  def setup
    @header = AppReputation::IosRatingsBuilder.class_variable_get(:@@header_user_agent)
    @resource = MiniTest::Mock.new
    countries = get_countries_from_stub_file(%w(US CN GB DE ES))
    AppReputation::IosRatingsBuilder.class_variable_set(:@@supported_countries, countries)
    @ios_ratings_builder = AppReputation::IosRatingsBuilder.new
  end
  
  def test_set_timeout
    timeout = 4
    AppReputation::IosRatingsBuilder.set_timeout(timeout)
    assert_equal(timeout, AppReputation::IosRatingsBuilder.class_variable_get(:@@timeout))
  end
  
  def test_set_max_retries
    max_retries = 2
    AppReputation::IosRatingsBuilder.set_max_retries(max_retries)
    assert_equal(max_retries, AppReputation::IosRatingsBuilder.class_variable_get(:@@max_retries))
  end
  
  def test_get_ratings_valid
    response = '{"ratingCountList":[1,2,3,5,8], "ratingCount": 19}'
    @resource.expect(:get, response, [@header])
    RestClient::Resource.stub(:new, @resource) do
      ratings = @ios_ratings_builder.send(:get_ratings, 123456789, 'us')
      assert_equal(AppReputation::Ratings.new(1,2,3,5,8), ratings)
    end
  end
  
  def test_get_ratings_invalid
    response = '{"iHaveNoRatingCountList": 0}'
    @resource.expect(:get, response, [@header])
    RestClient::Resource.stub(:new, @resource) do
      ratings = @ios_ratings_builder.send(:get_ratings, 123456789, 'us')
      assert_nil(ratings)
    end
  end
  
  def test_get_ratings_succeed_after_retry
    response = '{"ratingCountList":[1,2,3,5,8], "ratingCount": 19}'
    resource = mock()
    resource.stubs(:get).with(@header).raises(RestClient::RequestTimeout).then.returns(response)
    RestClient::Resource.stub(:new, resource) do
      ratings = @ios_ratings_builder.send(:get_ratings, 123456789, 'us')
      assert_equal(AppReputation::Ratings.new(1,2,3,5,8), ratings)
    end
  end
  
  def test_get_ratings_fail_all_retries
    def @resource.get(header)
      raise RestClient::RequestTimeout
    end
    RestClient::Resource.stub(:new, @resource) do
      assert_raises RestClient::RequestTimeout do
        @ios_ratings_builder.send(:get_ratings, 123456789, 'us')
      end
    end
  end
  
  def test_build_unsupported_countries
    assert_raises ArgumentError do
      @ios_ratings_builder.build(123456789, 'US', 'XX', 'OO')
    end
  end
  
  def test_build_with_one_country
    @ios_ratings_builder.expects(:get_ratings).with(123456789, 'CN').once
    @ios_ratings_builder.build(123456789, 'CN')
  end
end
