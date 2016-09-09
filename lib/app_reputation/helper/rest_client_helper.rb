require 'rest-client'

module AppReputation
  class RestClientHelper
    class << self
      def send_request(method, url, headers, payload = nil, &blk)
        args = {:method => method, :url => url, :verify_ssl => false, :headers => headers}
        args[:payload] = payload if payload
        
        begin
          response = RestClient::Request.execute(args)
          handle_response(response, headers, &blk)
        rescue RestClient::Unauthorized
          raise Exception::UnauthorizedError
        rescue RestClient::Found => e
          handle_response(e.response, headers, &blk)
        end
      end
      
      def handle_response(response, headers, &blk)
        cookies = headers.fetch(:cookies, {})
        # merge cookies if there is any redirect request
        response.history.each do |res|
          cookies.merge!(res.cookies)
        end
        cookies.merge!(response.cookies)
        headers.merge!({:cookies => cookies})
        
        if block_given?
          blk.call(response)
        end
        
        return response
      end
    end
    
    private_class_method :new, :handle_response
  end
end
