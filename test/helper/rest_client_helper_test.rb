require_relative '../test_helper'

class RestClientHelperTest < Minitest::Test
  def test_send_request_get_with_block
    headers = {'X-Requested-With' => 'XMLHttpRequest'}
    url = mock()
    response = mock()
    response_history = mock()
    response_history.stubs(:cookies).returns({'myacinfo' => 'f0F0f0F0'})
    response.stubs(:history).returns([response_history])
    response.stubs(:cookies).returns({'woinst' => '3072', 'wosid' => 'a1B2c3D4e5F6g7'})
    expected_cookies = {'myacinfo' => 'f0F0f0F0', 'woinst' => '3072', 'wosid' => 'a1B2c3D4e5F6g7'}
    expected_headers = headers.merge({:cookies => expected_cookies})
    RestClient::Request.stub(:execute, response) do
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
    response = mock()
    response.stubs(:history).returns([])
    response.stubs(:cookies).returns({'woinst' => '3072', 'wosid' => 'a1B2c3D4e5F6g7'})
    expected_cookies = {'woinst' => '3072', 'wosid' => 'a1B2c3D4e5F6g7'}
    expected_headers = headers.merge({:cookies => expected_cookies})
    RestClient::Request.stub(:execute, response) do
      AppReputation::RestClientHelper.send_request(:post, url, headers, payload)
      assert_equal(expected_headers, headers)
    end
  end
  
  def test_send_request_with_unauthorized_exception
    url = mock()
    headers = mock()
    payload = mock()
    RestClient::Request.stubs(:execute).with(any_parameters).raises(RestClient::Unauthorized)
    assert_raises AppReputation::Exception::UnauthorizedError do
      AppReputation::RestClientHelper.send_request(:post, url, headers, payload)
    end
  end
  
  def test_send_request_with_found_exception
    url = mock()
    headers = mock()
    payload = mock()
    response = mock()
    RestClient::Request.stubs(:execute).with(any_parameters).raises(RestClient::Found)
    RestClient::Found.any_instance.stubs(:response).returns(response)
    AppReputation::RestClientHelper.expects(:handle_response).with(response, headers).returns(response).once
    assert_equal(response, AppReputation::RestClientHelper.send_request(:post, url, headers, payload))
  end
end
