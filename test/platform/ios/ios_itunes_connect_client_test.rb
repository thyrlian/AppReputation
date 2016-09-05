require 'test_helper'

class IosItunesConnectClientTest < Minitest::Test
  def setup
    @client = AppReputation::IosItunesConnectClient.new('root', 'okok')
  end
  
  def test_authenticate
    response = mock()
    response.stubs(:history).returns([])
    response.stubs(:cookies).returns({'itunes' => 'connect'})
    response.stubs(:body).returns("123456\nvar itcServiceKey = 'xxxXxxx0101'\nABCDEF\n")
    expected_headers = {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json, text/javascript, */*',
      'Accept-Encoding' => 'gzip, deflate, br',
      'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/601.6.17 (KHTML, like Gecko) Version/9.1.1 Safari/601.6.17',
      'X-Apple-Widget-Key' => 'xxxXxxx0101',
      :cookies => {'itunes' => 'connect'}
    }
    RestClient::Request.stub(:execute, response) do
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
  
  def test_auth_and_process_with_socket_error
    @client.stubs(:authenticate).raises(SocketError)
    assert_raises RuntimeError do
      @client.send(:auth_and_process)
    end
  end
  
  def test_get_ratings
    test_json_file = File.join(File.dirname(__FILE__), 'itunes_connect_ratings.json')
    json = File.open(test_json_file, 'r') { |f| f.read }
    response = mock()
    response.stubs(:body).returns(json)
    AppReputation::RestClientHelper.stubs(:send_request).returns(response)
    ratings = @client.get_ratings(123456789)
    assert_equal(AppReputation::Ratings.new(1, 2, 3, 77, 88), ratings)
  end
  
  def test_get_installations
    test_json_file = File.join(File.dirname(__FILE__), 'itunes_connect_installations.json')
    json = File.open(test_json_file, 'r') { |f| f.read }
    response = mock()
    response.stubs(:body).returns(json)
    AppReputation::RestClientHelper.stubs(:send_request).returns(response)
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
