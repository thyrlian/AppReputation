require 'test_helper'

class AndroidGooglePlayDeveloperConsoleClientTest < Minitest::Test
  def setup
    @client = AppReputation::AndroidGooglePlayDeveloperConsoleClient.new('root', 'okok')
    @test_html = <<-EOF
      <html>
      <whatever>
      </whatever>
      <input name="Page" type="hidden" value="PasswordSeparationSignIn">
      <input type="hidden" name="GALX" value="iJlDexyz8aB">
      <input id="Email" name="Email" placeholder="Email" type="email" value="" spellcheck="false">
      <input type="hidden" id="dnConn" name="dnConn" value="">
      <input type="hidden" id="checkConnection" name="checkConnection">
      <input type="hidden" id="_utf8" name="_utf8" value="&#9731;"/>
      </html>
    EOF
  end
  
  def test_authenticate
    response = mock()
    response.stubs(:history).returns([])
    response.stubs(:cookies).returns({'play' => 'console'})
    response.stubs(:body).returns(@test_html)
    expected_headers = {
      'Content-Type' => 'application/x-www-form-urlencoded',
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Encoding' => 'gzip, deflate, br',
      'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36',
      :cookies => {'play' => 'console'}
    }
    RestClient::Request.stub(:execute, response) do
      @client.send(:authenticate)
      assert_equal(expected_headers, @client.headers)
    end
  end
  
  def test_compose_payload_without_block
    payload = @client.send(:compose_payload, @test_html)
    assert_equal({
      'Page' => 'PasswordSeparationSignIn',
      'GALX' => 'iJlDexyz8aB',
      'dnConn' => '',
      'checkConnection' => nil,
      '_utf8' => '☃'
    }, payload)
  end
  
  def test_compose_payload_with_block
    payload = @client.send(:compose_payload, @test_html) do |pl|
      pl.merge!({'secret' => '123abc'})
    end
    assert_equal({
      'Page' => 'PasswordSeparationSignIn',
      'GALX' => 'iJlDexyz8aB',
      'dnConn' => '',
      'checkConnection' => nil,
      '_utf8' => '☃',
      'secret' => '123abc'
    }, payload)
  end
end
