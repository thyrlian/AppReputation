require 'rest-client'

module AppReputation
  class RestClientHelper
    class << self
      def send_request(method, url, headers, payload = nil, &blk)
        args = {:method => method, :url => url, :verify_ssl => false, :headers => headers}
        args[:payload] = payload if payload
        
        begin
          response = RestClient::Request.execute(args)
          
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
    end
  end
end
