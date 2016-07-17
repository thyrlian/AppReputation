require 'json'
require 'rest-client'
require_relative '../ratings'
require_relative '../util/string'

module AppReputation
  class IosRatingsFetcherForItunesConnect
    @@auth_url = 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa'
    @@login_url = 'https://itunesconnect.apple.com/itc/static-resources/controllers/login_cntrl.js'
    @@signin_url = 'https://idmsa.apple.com/appleauth/auth/signin'
    @@ratings_url = 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/$[id]/reviews/summary?platform=ios'
    
    def get_ratings(id, username, password)
      headers = authenticate(username, password)
      ratings = nil
      begin
        url = @@ratings_url.set_param(:id, id)
        resource = RestClient::Resource.new(url, :verify_ssl => false)
        response = resource.get(headers)
        ratings = response.body
      rescue RestClient::Unauthorized => e
        puts "Cannot authorize account: #{username}"
        puts e.message
      end
      ratings
    end
    
    def authenticate(username, password)
      cookies = {}
      payload = {'accountName' => username, 'password' => password, 'rememberMe' => false}.to_json
      header_content_type = 'application/json'
      header_accept = 'application/json, text/javascript, */*'
      header_accept_encoding = 'gzip, deflate, br'
      header_user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/601.6.17 (KHTML, like Gecko) Version/9.1.1 Safari/601.6.17'
      headers = {'Content-Type' => header_content_type, 'Accept' => header_accept, 'Accept-Encoding' => header_accept_encoding, 'User-Agent' => header_user_agent}
      
      resource = RestClient::Resource.new(@@auth_url, :verify_ssl => false)
      response = resource.get(headers)
      response_cookies = response.history.first.cookies
      cookies.merge!(response_cookies)
      headers.merge!({:cookies => cookies})
      
      resource = RestClient::Resource.new(@@login_url, :verify_ssl => false)
      response = resource.get(headers)
      regex_widget_key = /var\sitcServiceKey\s*=\s*'(\w+)'/
      widget_key = regex_widget_key.match(response.body)
      headers['X-Apple-Widget-Key'] = widget_key[1] unless widget_key.nil?
      
      resource = RestClient::Resource.new(@@signin_url + "?widgetKey=#{widget_key[1]}", :verify_ssl => false)
      response = resource.get(headers)
      cookies.merge!(response.cookies)
      headers.merge!({:cookies => cookies})
      
      resource = RestClient::Resource.new(@@signin_url, :verify_ssl => false)
      response = resource.post(payload, headers)
      cookies.merge!(response.cookies)
      headers.merge!({:cookies => cookies})
      
      resource = RestClient::Resource.new(@@auth_url, :verify_ssl => false)
      response = resource.get(headers)
      
      headers
    end
    
    private :authenticate
  end
end
