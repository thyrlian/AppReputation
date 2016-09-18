require 'cgi'
require 'webrick'
require 'nokogiri'
require_relative '../../helper/rest_client_helper'

module AppReputation
  class AndroidGooglePlayDeveloperConsoleClient
    @@main_url = 'https://play.google.com/apps/publish/'
    @@login_url = 'https://accounts.google.com/accountLoginInfoXhr'
    @@signin_url = 'https://accounts.google.com/signin/challenge/sl/password'
    
    attr_reader :headers
    
    def initialize(username, password)
      @username = username
      @password = password
      @headers = {}
    end
    
    def authenticate
      header_connection = 'keep-alive'
      header_content_type = 'application/x-www-form-urlencoded'
      header_accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      header_accept_encoding = 'gzip, deflate, br'
      header_user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36'
      headers = {'Connection' => header_connection, 'Content-Type' => header_content_type, 'Accept' => header_accept, 'Accept-Encoding' => header_accept_encoding, 'User-Agent' => header_user_agent}
      
      payload = {}
      
      new_url = ''
      
      RestClientHelper.send_request(:get, @@main_url, headers) do |response|
        new_url = (Nokogiri::HTML(response.body).css('noscript').first.children.first.attribute('content').value.match(/url='(.*?)'/) || '')[1]
      end
      
      RestClientHelper.send_request(:get, new_url, headers) do |response|
        payload = compose_payload(response.body) do |pl|
          pl.merge!({
            'Email' => @username,
            'requestlocation' => new_url + '#identifier'
          })
        end
      end
      
      RestClientHelper.send_request(:post, @@login_url, headers.merge({'Referer' => new_url}), payload) do |response|
        payload['ProfileInformation'] = JSON.parse(response.body)['encoded_profile_information']
      end
      
      payload.delete('requestlocation')
      payload['Passwd'] = @password
      
      RestClientHelper.send_request(:post, @@signin_url, headers, payload) do |response|
        if response.code == 302
          new_url = response.headers[:location]
        end
      end
      
      @headers = headers
    end
    
    def compose_payload(html, &blk)
      regex_kvp = /<input\s.*?/
      regex_type = /type="hidden"/
      regex_name = /name="(.*?)"/
      regex_value = /value="(.*?)"/
      payload = html.split("\n").inject({}) do |hsh, line|
        if regex_kvp.match(line) && regex_type.match(line)
          name = regex_name.match(line)[1]
          value = (regex_value.match(line) || {})[1]
          value = CGI.unescapeHTML(value) if value
          hsh[name] = value
        end
        hsh
      end
      if block_given?
        blk.call(payload)
      end
      payload
    end
    
    private :compose_payload
  end
end
