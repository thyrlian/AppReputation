require 'rest-client'
require_relative '../util/string'
require_relative '../ratings'

module AppReputation
  class IosRatingsBuilder
    @@base_url = 'https://itunes.apple.com/$[country]/customer-reviews/id$[id]?dataOnly=true&displayable-kind=11&appVersion=all'
    @@header_user_agent = {'User-Agent' => 'iTunes/12.4.1 (Macintosh; OS X 10.11.5) AppleWebKit/601.6.17'}
    
    def build(id, country)
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
  end
end
