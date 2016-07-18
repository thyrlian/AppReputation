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
      @ios_ratings_fetcher.send(:send_request, :get, url, headers)
      assert_equal(expected_headers, headers)
    end
  end
  
  def test_send_request_post_without_block
  end
end
