require 'test_helper'

class StringTest < Minitest::Test
  def test_set_param_positive
    url = 'https://www.example.com/$[name]/intro'
    assert_equal('https://www.example.com/acme/intro', url.set_param(:name, 'acme'))
  end
  
  def test_set_param_negative
    url = 'https://www.example.com/about'
    assert_equal(url, url.set_param(:name, 'acme'))
  end
end
