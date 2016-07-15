require 'httparty'
require 'nokogiri'
require_relative '../ratings'

module AppReputation
  class AndroidRatingsBuilder
    @@base_url = 'https://play.google.com/store/apps/details?id='
    
    def build(id)
      url = @@base_url + id
      page = HTTParty.get(url, :verify => false)
      doc = Nokogiri::HTML(page)
      statistics = %w(one two three four five).inject([]) do |ratings, star|
        css_query = '.rating-histogram'
        xpath_query = "//div[@class='rating-bar-container #{star}']/span[@class='bar-number']"
        tag_name = 'span'
        element = doc.css(css_query).xpath(xpath_query).at(tag_name)
        unless element.nil?
          ratings.push(element.children.text.tr(',.', '').to_i)
        else
          ratings
        end
      end
      statistics.empty? ? nil : Ratings.new(*statistics)
    end
  end
end
