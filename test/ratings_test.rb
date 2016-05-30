require 'test_helper'

class RatingsTest < Minitest::Test
  def test_average_float
    ratings = AppReputation::Ratings.new(538, 216, 491, 1187, 4758)
    assert_equal(4.308901251738526, ratings.average)
  end
  
  def test_average_int
    ratings = AppReputation::Ratings.new(100, 50, 3, 50, 100)
    assert_equal(3, ratings.average)
  end
  
  def test_average_zero
    ratings = AppReputation::Ratings.new(0, 0, 0, 0, 0)
    assert_equal(0, ratings.average)
  end
end
