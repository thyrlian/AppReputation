require 'test_helper'

class IosRatingsFetcherForItunesConnectTest < Minitest::Test
  def setup
    @ios_ratings_fetcher = AppReputation::IosRatingsFetcherForItunesConnect.new
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
      @ios_ratings_fetcher.send(:send_request, :get, url, headers) do |res|
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
      @ios_ratings_fetcher.send(:send_request, :post, url, headers, payload)
      assert_equal(expected_headers, headers)
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
      headers = @ios_ratings_fetcher.send(:authenticate, 'root', 'pass')
      assert_equal(expected_headers, headers)
    end
  end
  
  def test_get_ratings_successfully
    test_json_file = File.join(File.dirname(__FILE__), 'itunes_connect_ratings.json')
    json = File.open(test_json_file, 'r') { |f| f.read }
    headers = mock()
    response = mock()
    response.stubs(:body).returns(json)
    @ios_ratings_fetcher.stubs(:authenticate).returns(headers)
    @ios_ratings_fetcher.stubs(:send_request).returns(response)
    ratings = @ios_ratings_fetcher.get_ratings(123456789, 'username', 'password')
    assert_equal(AppReputation::Ratings.new(1, 2, 3, 77, 88), ratings)
  end
end
