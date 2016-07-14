require 'rest-client'
require_relative '../ratings'
require_relative '../util/string'
require_relative '../util/countries'
require_relative '../util/concurrent_runner'

module AppReputation
  class IosRatingsBuilder
    @@base_url_itunes_client = 'https://itunes.apple.com/$[country]/customer-reviews/id$[id]?dataOnly=true&displayable-kind=11&appVersion=all'
    @@header_user_agent = {'User-Agent' => 'iTunes/12.4.1 (Macintosh; OS X 10.11.5) AppleWebKit/601.6.17'}
    @@timeout = 3
    @@max_retries = 3
    @@supported_countries = Countries.parse(File.join(File.dirname(__FILE__), 'ios_country_code_list.txt'))
    
    class << self
      def set_timeout(timeout)
        @@timeout = timeout
      end
      
      def set_max_retries(max_retries)
        @@max_retries = max_retries
      end
    end
    
    def build(id, *countries)
      unless @@supported_countries.include?(*countries)
        unsupported_countries = @@supported_countries.list_unsupported_countries(*countries)
        raise ArgumentError, "Unsupported countries: #{unsupported_countries}"
      end
      case countries.size
      when 0
        get_multiple_ratings_concurrently(id, *@@supported_countries.list)
      when 1
        get_ratings(id, countries.first)
      else
        get_multiple_ratings_concurrently(id, *countries)
      end
    end
    
    def get_ratings(id, country)
      url = @@base_url_itunes_client.set_param(:country, country).set_param(:id, id)
      resource = RestClient::Resource.new(url, :verify_ssl => false, :open_timeout => @@timeout)
      now_retry = 0
      begin
        response = resource.get(@@header_user_agent)
        statistics = JSON.parse(response)['ratingCountList']
      rescue RestClient::RequestTimeout => e
        if now_retry < @@max_retries
          now_retry += 1
          retry
        else
          raise e
        end
      end
      if statistics
        return Ratings.new(*statistics)
      else
        return nil
      end
    end
    
    def get_multiple_ratings_concurrently(id, *countries)
      jobs = countries.inject([]) do |memo, country|
        job = Proc.new do
          get_ratings(id, country)
        end
        memo.push(job)
      end
      concurrent_runner = ConcurrentRunner.set
      concurrent_runner.set_consumer_thread
      concurrent_runner.set_producer_thread(jobs)
      concurrent_runner.run
      concurrent_runner.results.inject(Ratings.new(0, 0, 0, 0, 0)) do |sum, ratings|
        sum + ratings
      end
    end
    
    private :get_ratings, :get_multiple_ratings_concurrently
  end
end
