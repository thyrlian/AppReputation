require 'test_helper'

class AppReputationTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::AppReputation::VERSION
  end
end
