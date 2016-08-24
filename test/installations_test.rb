require 'test_helper'

class InstallationsTest < Minitest::Test
  def test_initialize
    installations = AppReputation::Installations.new('2012-12-21', 1024)
    assert_equal(Date.new(2012, 12, 21), installations.date)
    assert_equal(1024, installations.count)
  end
  
  def test_equal
    a = AppReputation::Installations.new('2012-12-21', 1024)
    b = AppReputation::Installations.new('2012-12-21', 1024)
    c = AppReputation::Installations.new('2012-12-21', 768)
    d = AppReputation::Installations.new('2011-11-11', 1024)
    e = AppReputation::Installations.new('2011-11-11', 768)
    assert(a == b)
    refute(a == c)
    refute(a == d)
    refute(a == e)
    refute(a == nil)
  end
end
