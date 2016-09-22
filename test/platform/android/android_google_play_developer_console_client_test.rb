require 'test_helper'

class AndroidGooglePlayDeveloperConsoleClientTest < Minitest::Test
  def setup
    @client = AppReputation::AndroidGooglePlayDeveloperConsoleClient.new('root', 'okok')
    @test_html_1 = <<-EOF
      <!DOCTYPE html><html><head><title>Redirecting...</title><script type="text/javascript" language="javascript">var url = 'https:\/\/accounts.google.com\/ServiceLogin?service\x3dandroiddeveloper\x26passive\x3d1209600\x26continue\x3dhttps:\/\/play.google.com\/apps\/publish\/%23__HASH__\x26followup\x3dhttps:\/\/play.google.com\/apps\/publish\/'; var fragment = ''; if (self.document.location.hash) {fragment = self.document.location.hash.replace(/^#/,'');}url = url.replace(new RegExp("__HASH__", 'g'), encodeURIComponent(fragment));window.location.assign(url);</script><noscript><meta http-equiv="refresh" content="0; url='https://accounts.google.com/ServiceLogin?service&#61;androiddeveloper&amp;passive&#61;1209600&amp;continue&#61;https://play.google.com/apps/publish/&amp;followup&#61;https://play.google.com/apps/publish/'"></meta></noscript></head><body></body></html>
    EOF
    @test_html_2 = <<-EOF
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
    @test_json = '{"email": "acme@example.com","shadow_email": "","encoded_profile_information": "ATM1q2w3e4r5t6y7u8i9o0p","action": "ASK_PASSWORD"}'
  end
  
  def test_authenticate
    response = mock()
    response.stubs(:history).returns([])
    response.stubs(:cookies).returns({'play' => 'console'})
    response.stubs(:body).returns(@test_html_1).then.returns(@test_html_2).then.returns(@test_json)
    response.stubs(:code).returns(302)
    response.stubs(:headers).returns({:location => 'https://accounts.google.com/CheckCookie?checkedDomains=youtube&chtml=LoginDoneHtml&gidl=ABCDefgh'})
    expected_headers = {
      'Connection' => 'keep-alive',
      'Upgrade-Insecure-Requests' => '1',
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Encoding' => 'gzip, deflate, sdch, br',
      'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36',
      :cookies => {'play' => 'console'}
    }
    RestClient::Request.stub(:execute, response) do
      @client.send(:authenticate)
      assert_equal(expected_headers, @client.headers)
    end
  end
  
  def test_compose_payload_without_block
    payload = @client.send(:compose_payload, @test_html_2)
    assert_equal({
      'Page' => 'PasswordSeparationSignIn',
      'GALX' => 'iJlDexyz8aB',
      'dnConn' => '',
      'checkConnection' => nil,
      '_utf8' => '☃'
    }, payload)
  end
  
  def test_compose_payload_with_block
    payload = @client.send(:compose_payload, @test_html_2) do |pl|
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
