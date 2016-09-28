require_relative '../test_helper'

class StringTest < Minitest::Test
  def test_set_param_positive
    url = 'https://www.example.com/$[name]/intro'
    assert_equal('https://www.example.com/acme/intro', url.set_param(:name, 'acme'))
    assert_equal('https://www.example.com/$[name]/intro', url)
  end
  
  def test_set_param_negative
    url = 'https://www.example.com/about'
    assert_equal(url, url.set_param(:name, 'acme'))
  end
  
  def test_escape_uri_positive
    string = "https:\\x2F\\x2Faccounts.google.com\\x2Faccounts"
    expected = 'https://accounts.google.com/accounts'
    assert_equal(expected, string.escape_uri)
  end
  
  def test_escape_uri_negative
    string = 'This is a test!!!'
    assert_equal(string, string.escape_uri)
  end
end
