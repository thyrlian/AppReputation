require_relative '../test_helper'

class RestClientHelperTest < Minitest::Test
  def test_send_request_with_payload_and_block
    method = mock()
    url = mock()
    headers = mock()
    payload = mock()
    response = mock()
    args = {:method => method, :url => url, :verify_ssl => false, :headers => headers, :payload => payload}
    
    RestClient::Request.expects(:execute).with(args).returns(response).once
    AppReputation::RestClientHelper.stubs(:handle_response).with(response, headers).returns(response).once
    
    actual_response = AppReputation::RestClientHelper.send_request(method, url, headers, payload) do |res|
      assert_equal(response, res)
    end
    assert_equal(response, actual_response)
  end
  
  def test_send_request_without_payload_or_block
    method = mock()
    url = mock()
    headers = mock()
    response = mock()
    args = {:method => method, :url => url, :verify_ssl => false, :headers => headers}
    
    RestClient::Request.expects(:execute).with(args).returns(response).once
    AppReputation::RestClientHelper.stubs(:handle_response).with(response, headers).returns(response).once
    
    actual_response = AppReputation::RestClientHelper.send_request(method, url, headers)
    assert_equal(response, actual_response)
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
  
  def test_handle_response
    headers = {'X-Info' => '001024'}
    response = mock()
    response_history = mock()
    response_history.stubs(:cookies).returns({'code' => 'f0F0f0F0'})
    response.stubs(:cookies).returns({'secret' => '1a2b3cXYZ', 'key' => 'a1B2c3D4e5F6g7'})
    response.stubs(:history).returns([response_history])
    
    expected_cookies = {'secret' => '1a2b3cXYZ', 'key' => 'a1B2c3D4e5F6g7', 'code' => 'f0F0f0F0'}
    expected_headers = headers.merge({:cookies => expected_cookies})
    
    actual_response = AppReputation::RestClientHelper.send(:handle_response, response, headers) do |res|
      assert_equal(response, res)
    end
    
    assert_equal(response, actual_response)
    assert_equal(expected_headers, headers)
  end
end
