require 'rest-client'

module AppReputation
  class RestClientHelper
    class << self
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
    end
  end
end
