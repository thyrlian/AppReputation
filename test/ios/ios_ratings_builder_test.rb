require 'test_helper'

class IosRatingsBuilderTest < Minitest::Test
  def test_get_ratings_valid
    header = AppReputation::IosRatingsBuilder.class_variable_get(:@@header_user_agent)
    response = '{"ratingCountList":[1,2,3,5,8], "ratingCount": 19}'
    resource = MiniTest::Mock.new
    resource.expect(:get, response, [header])
    ios_ratings_builder = AppReputation::IosRatingsBuilder.new
    RestClient::Resource.stub(:new, resource) do
      ratings = ios_ratings_builder.send(:get_ratings, 123456789, 'us')
      assert_equal(AppReputation::Ratings.new(1,2,3,5,8), ratings)
    end
  end
  
  def test_get_ratings_invalid
    header = AppReputation::IosRatingsBuilder.class_variable_get(:@@header_user_agent)
    response = '{"iHaveNoRatingCountList": 0}'
    resource = MiniTest::Mock.new
    resource.expect(:get, response, [header])
    ios_ratings_builder = AppReputation::IosRatingsBuilder.new
    RestClient::Resource.stub(:new, resource) do
      ratings = ios_ratings_builder.send(:get_ratings, 123456789, 'us')
      assert_nil(ratings)
    end
  end
end
