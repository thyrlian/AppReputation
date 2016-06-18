require 'test_helper'

class IosRatingsBuilderTest < Minitest::Test
  def setup
    @header = AppReputation::IosRatingsBuilder.class_variable_get(:@@header_user_agent)
    @resource = MiniTest::Mock.new
    @ios_ratings_builder = AppReputation::IosRatingsBuilder.new
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
