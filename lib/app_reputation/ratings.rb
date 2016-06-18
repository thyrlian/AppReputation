module AppReputation
  class Ratings
    attr_reader :statistics
    
    def initialize(*statistics)
      # statistics start from one star to top stars
      @statistics = statistics
    end
    
    def average
      gross = @statistics.each_with_index.inject(0) do |sum, (item, index)|
        # count is item
        # stars is index + 1
        sum + item * (index + 1)
      end
      if (gross == 0)
        return 0
      else
        return gross * 1.0 / @statistics.inject(:+)
      end
    end
    
    def ==(another_ratings)
      @statistics = another_ratings.statistics
    end
  end
end
