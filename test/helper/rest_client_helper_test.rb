require_relative '../test_helper'

class RestClientHelperTest < Minitest::Test
  def test_send_request_get_with_block
    headers = {'X-Requested-With' => 'XMLHttpRequest'}
    url = mock()
    resource = mock()
    response = mock()
    response_history = mock()
    resource.stubs(:get).with(headers).returns(response)
    response_history.stubs(:cookies).returns({'myacinfo' => 'f0F0f0F0'})
    response.stubs(:history).returns([response_history])
    response.stubs(:cookies).returns({'woinst' => '3072', 'wosid' => 'a1B2c3D4e5F6g7'})
    expected_cookies = {'myacinfo' => 'f0F0f0F0', 'woinst' => '3072', 'wosid' => 'a1B2c3D4e5F6g7'}
    expected_headers = headers.merge({:cookies => expected_cookies})
    RestClient::Resource.stub(:new, resource) do
      AppReputation::RestClientHelper.send_request(:get, url, headers) do |res|
        assert_equal(response, res)
      end
      assert_equal(expected_headers, headers)
    end
  end
  
  def test_send_request_post_without_block
    headers = {'X-Requested-With' => 'XMLHttpRequest'}
    payload = {'what' => 'ever'}
    url = mock()
    resource = mock()
    response = mock()
    resource.stubs(:post).with(payload, headers).returns(response)
    response.stubs(:history).returns([])
    response.stubs(:cookies).returns({'woinst' => '3072', 'wosid' => 'a1B2c3D4e5F6g7'})
    expected_cookies = {'woinst' => '3072', 'wosid' => 'a1B2c3D4e5F6g7'}
    expected_headers = headers.merge({:cookies => expected_cookies})
    RestClient::Resource.stub(:new, resource) do
      AppReputation::RestClientHelper.send_request(:post, url, headers, payload)
      assert_equal(expected_headers, headers)
    end
  end
  
  def test_send_request_with_unknown_method
    url = mock()
    headers = mock()
    payload = mock()
    resource = mock()
    RestClient::Resource.stub(:new, resource) do
      assert_raises NotImplementedError do
        AppReputation::RestClientHelper.send_request(:pxt, url, headers, payload)
      end
    end
  end
  
  def test_send_request_with_unauthorized_error
    url = mock()
    headers = mock()
    payload = mock()
    resource = mock()
    resource.stubs(:post).with(payload, headers).raises(RestClient::Unauthorized)
    RestClient::Resource.stub(:new, resource) do
      assert_raises AppReputation::Exception::UnauthorizedError do
        AppReputation::RestClientHelper.send_request(:post, url, headers, payload)
      end
    end
  end
end
