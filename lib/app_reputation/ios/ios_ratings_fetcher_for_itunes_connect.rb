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
        ratings = send_request(:get, url, headers).body
      rescue RestClient::Unauthorized => e
        puts "Cannot authorize account: #{username}"
        puts e.message
      end
      ratings
    end
    
    def authenticate(username, password)
      payload = {'accountName' => username, 'password' => password, 'rememberMe' => false}.to_json
      header_content_type = 'application/json'
      header_accept = 'application/json, text/javascript, */*'
      header_accept_encoding = 'gzip, deflate, br'
      header_user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/601.6.17 (KHTML, like Gecko) Version/9.1.1 Safari/601.6.17'
      headers = {'Content-Type' => header_content_type, 'Accept' => header_accept, 'Accept-Encoding' => header_accept_encoding, 'User-Agent' => header_user_agent}
      
      send_request(:get, @@auth_url, headers)
      send_request(:get, @@login_url, headers) do |response|
        regex_widget_key = /var\sitcServiceKey\s*=\s*'(\w+)'/
        widget_key = regex_widget_key.match(response.body)
        headers['X-Apple-Widget-Key'] = widget_key[1] unless widget_key.nil?
      end
      send_request(:post, @@signin_url, headers, payload)
      send_request(:get, @@auth_url, headers)
      
      headers
    end
    
    def send_request(method, url, headers, payload = nil, &blk)
      resource = RestClient::Resource.new(url, :verify_ssl => false)
      args = []
      case method
      when :get
        args.push(headers)
      when :post
        args.push(payload, headers)
      end
      response = resource.send(method, *args)
      
      if block_given?
        blk.call(response)
      end
      
      cookies = headers.fetch(:cookies, {})
      # merge cookies if there is any redirect request
      response.history.each do |res|
        cookies.merge!(res.cookies)
      end
      cookies.merge!(response.cookies)
      headers.merge!({:cookies => cookies})
      
      response
    end
    
    private :authenticate, :send_request
  end
end
