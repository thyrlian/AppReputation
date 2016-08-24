require 'test_helper'

class IosItunesConnectClientTest < Minitest::Test
  def setup
    @client = AppReputation::IosItunesConnectClient.new('root', 'okok')
  end
  
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
      @client.send(:send_request, :get, url, headers) do |res|
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
      @client.send(:send_request, :post, url, headers, payload)
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
        @client.send(:send_request, :pxt, url, headers, payload)
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
        @client.send(:send_request, :post, url, headers, payload)
      end
    end
  end
  
  def test_authenticate
    response = mock()
    resource = mock()
    response.stubs(:history).returns([])
    response.stubs(:cookies).returns({'itunes' => 'connect'})
    response.stubs(:body).returns("123456\nvar itcServiceKey = 'xxxXxxx0101'\nABCDEF\n")
    resource.stubs(:get).returns(response)
    resource.stubs(:post).returns(response)
    expected_headers = {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json, text/javascript, */*',
      'Accept-Encoding' => 'gzip, deflate, br',
      'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/601.6.17 (KHTML, like Gecko) Version/9.1.1 Safari/601.6.17',
      'X-Apple-Widget-Key' => 'xxxXxxx0101',
      :cookies => {'itunes' => 'connect'}
    }
    RestClient::Resource.stub(:new, resource) do
      @client.send(:authenticate)
      assert_equal(expected_headers, @client.headers)
    end
  end
  
  def test_auth_and_process_without_block
    headers = mock()
    @client.stubs(:authenticate).returns(headers)
    @client.send(:auth_and_process)
  end
  
  def test_auth_and_process_with_block
    test_obj = 10
    headers = mock()
    @client.stubs(:authenticate).returns(headers)
    @client.send(:auth_and_process) do
      test_obj = 1024
    end
    assert_equal(1024, test_obj)
  end
  
  def test_auth_and_process_with_unauthorized_error
    @client.stubs(:authenticate).raises(AppReputation::Exception::UnauthorizedError)
    assert_raises AppReputation::Exception::UnauthorizedError do
      @client.send(:auth_and_process)
    end
  end
  
  def test_get_ratings
    test_json_file = File.join(File.dirname(__FILE__), 'itunes_connect_ratings.json')
    json = File.open(test_json_file, 'r') { |f| f.read }
    response = mock()
    response.stubs(:body).returns(json)
    @client.stubs(:send_request).returns(response)
    ratings = @client.get_ratings(123456789)
    assert_equal(AppReputation::Ratings.new(1, 2, 3, 77, 88), ratings)
  end
  
  def test_get_installations
    test_json_file = File.join(File.dirname(__FILE__), 'itunes_connect_installations.json')
    json = File.open(test_json_file, 'r') { |f| f.read }
    response = mock()
    response.stubs(:body).returns(json)
    @client.stubs(:send_request).returns(response)
    installations = @client.get_installations(123456789)
    expected_installations = [
      AppReputation::Installations.new('2016-08-18', 1200),
      AppReputation::Installations.new('2016-08-19', 900),
      AppReputation::Installations.new('2016-08-20', 800),
      AppReputation::Installations.new('2016-08-21', 1500),
      AppReputation::Installations.new('2016-08-22', 1000),
      AppReputation::Installations.new('2016-08-23', 1024)
    ]
    assert_equal(expected_installations, installations)
  end
end
