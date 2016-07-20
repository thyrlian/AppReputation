require 'json'
require 'rest-client'
require_relative '../../ratings'
require_relative '../../util/string'
require_relative '../../exception/exception'

module AppReputation
  class IosItunesConnectClient
    @@auth_url = 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa'
    @@login_url = 'https://itunesconnect.apple.com/itc/static-resources/controllers/login_cntrl.js'
    @@signin_url = 'https://idmsa.apple.com/appleauth/auth/signin'
    @@ratings_url = 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/$[id]/reviews/summary?platform=ios'
    
    attr_reader :headers
    
    def initialize(username, password)
      @username = username
      @password = password
      @headers = {}
    end
    
    def send_request(method, url, headers, payload = nil, &blk)
      resource = RestClient::Resource.new(url, :verify_ssl => false)
      args = []
      case method
      when :get
        args.push(headers)
      when :post
        args.push(payload, headers)
      else
        raise(NotImplementedError, "Method [ #{method} ] is not implemented in #{__method__}", caller)
      end
      
      begin
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
        
        return response
      rescue RestClient::Unauthorized
        raise Exception::UnauthorizedError
      end
    end
    
    def authenticate
      payload = {'accountName' => @username, 'password' => @password, 'rememberMe' => false}.to_json
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
      
      @headers = headers
    end
    
    def get_ratings(id)
      ratings = nil
      begin
        authenticate if @headers.empty?
        url = @@ratings_url.set_param(:id, id)
        response = send_request(:get, url, @headers).body
        json = JSON.parse(response)
        if json['statusCode'] == 'SUCCESS'
          ratings_data = json['data']['ratings']
          statistics = []
          statistics.push(ratings_data['ratingOneCount'])
          statistics.push(ratings_data['ratingTwoCount'])
          statistics.push(ratings_data['ratingThreeCount'])
          statistics.push(ratings_data['ratingFourCount'])
          statistics.push(ratings_data['ratingFiveCount'])
          ratings = Ratings.new(*statistics)
        end
      rescue Exception::UnauthorizedError
        raise(Exception::UnauthorizedError, {'username' => @username, 'password' => @password})
      end
      ratings
    end
    
    private :send_request
  end
end
