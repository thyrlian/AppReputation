require 'test_helper'
require_relative '../util/countries_test_helper'

class IosRatingsFetcherForItunesClientTest < Minitest::Test
  include CountriesTestHelper
  
  def setup
    @header = AppReputation::IosRatingsFetcherForItunesClient.class_variable_get(:@@header_user_agent)
    @resource = MiniTest::Mock.new
    countries = get_countries_from_stub_file(%w(US CN GB DE ES))
    AppReputation::IosRatingsFetcherForItunesClient.class_variable_set(:@@supported_countries, countries)
    @ios_ratings_fetcher = AppReputation::IosRatingsFetcherForItunesClient.new
  end
  
  def test_set_timeout
    timeout = 4
    AppReputation::IosRatingsFetcherForItunesClient.set_timeout(timeout)
    assert_equal(timeout, AppReputation::IosRatingsFetcherForItunesClient.class_variable_get(:@@timeout))
  end
  
  def test_set_max_retries
    max_retries = 2
    AppReputation::IosRatingsFetcherForItunesClient.set_max_retries(max_retries)
    assert_equal(max_retries, AppReputation::IosRatingsFetcherForItunesClient.class_variable_get(:@@max_retries))
  end
  
  def test_get_single_ratings_valid
    response = '{"ratingCountList":[1,2,3,5,8], "ratingCount": 19}'
    @resource.expect(:get, response, [@header])
    RestClient::Resource.stub(:new, @resource) do
      ratings = @ios_ratings_fetcher.send(:get_single_ratings, 123456789, 'us')
      assert_equal(AppReputation::Ratings.new(1, 2, 3, 5, 8), ratings)
    end
  end
  
  def test_get_single_ratings_invalid
    response = '{"iHaveNoRatingCountList": 0}'
    @resource.expect(:get, response, [@header])
    RestClient::Resource.stub(:new, @resource) do
      ratings = @ios_ratings_fetcher.send(:get_single_ratings, 123456789, 'us')
      assert_nil(ratings)
    end
  end
  
  def test_get_ratings_succeed_after_retry
    response = '{"ratingCountList":[1,2,3,5,8], "ratingCount": 19}'
    resource = mock()
    resource.stubs(:get).with(@header).raises(RestClient::RequestTimeout).then.returns(response)
    RestClient::Resource.stub(:new, resource) do
      ratings = @ios_ratings_fetcher.send(:get_single_ratings, 123456789, 'us')
      assert_equal(AppReputation::Ratings.new(1, 2, 3, 5, 8), ratings)
    end
  end
  
  def test_get_ratings_fail_all_retries
    resource = mock()
    resource.stubs(:get).with(@header).raises(RestClient::RequestTimeout)
    RestClient::Resource.stub(:new, resource) do
      assert_raises RestClient::RequestTimeout do
        @ios_ratings_fetcher.send(:get_single_ratings, 123456789, 'us')
      end
    end
  end
  
  def test_get_multiple_ratings
    @ios_ratings_fetcher.expects(:get_single_ratings).with(123456789, 'cn').returns(AppReputation::Ratings.new(1, 2, 3, 4, 5)).once
    @ios_ratings_fetcher.expects(:get_single_ratings).with(123456789, 'de').returns(AppReputation::Ratings.new(0, 1, 1, 2, 3)).once
    @ios_ratings_fetcher.expects(:get_single_ratings).with(123456789, 'us').returns(AppReputation::Ratings.new(9, 9, 9, 9, 9)).once
    ratings = @ios_ratings_fetcher.send(:get_multiple_ratings, 123456789, 'cn', 'de', 'us')
    assert_equal(AppReputation::Ratings.new(10, 12, 13, 15, 17), ratings)
  end
  
  def test_get_ratings_with_unsupported_countries
    assert_raises ArgumentError do
      @ios_ratings_fetcher.get_ratings(123456789, 'US', 'XX', 'OO')
    end
  end
  
  def test_get_ratings_with_one_country
    ratings = AppReputation::Ratings.new(6, 5, 5, 3, 6)
    @ios_ratings_fetcher.expects(:get_single_ratings).with(123456789, 'CN').returns(ratings).once
    assert_equal(ratings, @ios_ratings_fetcher.get_ratings(123456789, 'CN'))
  end
  
  def test_get_ratings_with_more_countries
    ratings = AppReputation::Ratings.new(3, 1, 4, 1, 5)
    @ios_ratings_fetcher.expects(:get_multiple_ratings).with(123456789, 'US', 'GB', 'ES').returns(ratings).once
    assert_equal(ratings, @ios_ratings_fetcher.get_ratings(123456789, 'US', 'GB', 'ES'))
  end
  
  def test_get_ratings_with_all_countries
    ratings = AppReputation::Ratings.new(1, 10, 100, 1000, 10000)
    @ios_ratings_fetcher.expects(:get_multiple_ratings).with(123456789, 'US', 'CN', 'GB', 'DE', 'ES').returns(ratings).once
    assert_equal(ratings, @ios_ratings_fetcher.get_ratings(123456789))
  end
end
