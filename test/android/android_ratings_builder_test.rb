require 'test_helper'

class AndroidRatingsBuilderTest < Minitest::Test
  def setup
    test_html_file = File.join(File.dirname(__FILE__), 'android_play_store_html')
    @page = File.open(test_html_file, 'r') { |f| f.read }
    @android_ratings_builder = AppReputation::AndroidRatingsBuilder.new
  end
  
  def test_build_with_valid_id
    url = MiniTest::Mock.new
    ratings = AppReputation::Ratings.new(111, 1000, 10000, 100000, 1123456)
    HTTParty.stub(:get, @page, url) do
      assert_equal(ratings, @android_ratings_builder.build('com.basgeekball.app'))
    end
  end
  
  def test_build_with_invalid_id
    url = MiniTest::Mock.new
    HTTParty.stub(:get, '', url) do
      assert_nil(@android_ratings_builder.build('com.example.app'))
    end
  end
end
