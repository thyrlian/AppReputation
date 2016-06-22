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
  
  def test_equal
    a = AppReputation::Ratings.new(23, 9, 13, 91, 33)
    b = AppReputation::Ratings.new(23, 9, 13, 91, 33)
    c = AppReputation::Ratings.new(23, 5, 24, 54, 33)
    assert(a == b)
    refute(a == c)
    refute(b == nil)
  end
  
  def test_add
    a = AppReputation::Ratings.new(23, 9, 13, 91, 33)
    b = AppReputation::Ratings.new(23, 5, 24, 54, 33)
    c = AppReputation::Ratings.new(46, 14, 37, 145, 66)
    d = AppReputation::Ratings.new(23, 9, 13, 91, 33, 7)
    assert((a + b) == c)
    assert((a + nil) == a)
    assert_raises ArgumentError do
      a + d
    end
  end
end
