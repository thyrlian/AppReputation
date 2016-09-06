require 'uri'
require_relative '../../helper/rest_client_helper'

module AppReputation
  class AndroidGooglePlayDeveloperConsoleClient
    @@continue_url = 'https://play.google.com/apps/publish/#'
    @@followup_url = 'https://play.google.com/apps/publish/'
    @@main_url = 'https://play.google.com/apps/publish/'
    @@login_url = "https://accounts.google.com/ServiceLogin?service=androiddeveloper&passive=1209600&continue=#{URI.escape(@@continue_url)}&followup=#{@@followup_url}"
    
    attr_reader :headers
    
    def initialize(username, password)
      @username = username
      @password = password
      @headers = {}
    end
    
    def authenticate
      header_content_type = 'application/x-www-form-urlencoded'
      header_accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      header_accept_encoding = 'gzip, deflate, br'
      header_user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36'
      headers = {'Content-Type' => header_content_type, 'Accept' => header_accept, 'Accept-Encoding' => header_accept_encoding, 'User-Agent' => header_user_agent}
      
      RestClientHelper.send_request(:get, @@main_url, headers)
      RestClientHelper.send_request(:get, @@login_url, headers)
      
      @headers = headers
    end
  end
end
