require 'rest-client'
require_relative '../ratings'
require_relative '../util/string'
require_relative '../util/countries'

module AppReputation
  class IosRatingsBuilder
    @@base_url = 'https://itunes.apple.com/$[country]/customer-reviews/id$[id]?dataOnly=true&displayable-kind=11&appVersion=all'
    @@header_user_agent = {'User-Agent' => 'iTunes/12.4.1 (Macintosh; OS X 10.11.5) AppleWebKit/601.6.17'}
    @@supported_countries = Countries.parse(File.join(File.dirname(__FILE__), 'ios_country_code_list.txt'))
    
    def build(id, *countries)
      unless @@supported_countries.include?(*countries)
        unsupported_countries = @@supported_countries.list_unsupported_countries(*countries)
        raise ArgumentError, "Unsupported countries: #{unsupported_countries}"
      end
      case countries.size
      when 0
        puts 'Get ratings from all countrie'
      when 1
        return get_ratings(id, countries.first)
      else
        puts "Get ratings from #{countries}"
      end
    end
    
    def get_ratings(id, country)
      url = @@base_url.set_param(:country, country).set_param(:id, id)
      resource = RestClient::Resource.new(url, :verify_ssl => false)
      response = resource.get(@@header_user_agent)
      statistics = JSON.parse(response)['ratingCountList']
      if statistics
        return Ratings.new(*statistics)
      else
        return nil
      end
    end
    
    private :get_ratings
  end
end
