require 'json'
require 'rest-client'
require_relative '../../ratings'
require_relative '../../installations'
require_relative '../../util/string'
require_relative '../../exception/exception'

module AppReputation
  class IosItunesConnectClient
    @@auth_url = 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa'
    @@login_url = 'https://itunesconnect.apple.com/itc/static-resources/controllers/login_cntrl.js'
    @@signin_url = 'https://idmsa.apple.com/appleauth/auth/signin'
    @@ratings_url = 'https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/$[id]/reviews/summary?platform=ios'
    @@installations_url = 'https://reportingitc2.apple.com/api/data/timeseries'
    
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
    
    def auth_and_process(&blk)
      begin
        authenticate if @headers.empty?
        if block_given?
          blk.call
        end
      rescue Exception::UnauthorizedError
        raise(Exception::UnauthorizedError, {'username' => @username, 'password' => @password})
      end
    end
    
    def get_ratings(id)
      ratings = nil
      auth_and_process do
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
      end
      ratings
    end
    
    def get_installations(id)
      installations = nil
      auth_and_process do
        now = Time.now
        date_format = '%Y-%m-%dT00:00:00.000Z'
        start_date = (now - 6*24*60*60).strftime(date_format)
        end_date = now.strftime(date_format)
        payload = {
          'filters' => [{'dimension_key' => 'content', 'option_keys' => [id.to_s]}],
          'group' => 'content',
          'interval' => 'day',
          'start_date' => start_date,
          'end_date' => end_date,
          'sort' => 'descending',
          'limit' => 100,
          'measures' => ['units_utc']
        }.to_json
        response = send_request(:post, @@installations_url, @headers, payload).body
        json = JSON.parse(response)
        regex_date = /\d{4}-\d{2}-\d{2}/
        installations = json.first['data'].inject([]) do |all_days, one_day|
          all_days.push(Installations.new(regex_date.match(one_day['date'])[0], one_day['units_utc']))
        end
      end
      installations
    end
    
    private :send_request, :authenticate, :auth_and_process
  end
end
