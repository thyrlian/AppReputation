module AppReputation
  class Ratings
    attr_reader :statistics
    
    def initialize(*statistics)
      # statistics start from one star to top stars
      @statistics = statistics
    end
    
    def average
      sum = @statistics.each_with_index.inject(0) do |sum, (item, index)|
        # count is item
        # stars is index + 1
        sum += item * (index + 1)
      end
      if (sum == 0)
        return 0
      else
        return sum * 1.0 / @statistics.inject(:+)
      end
    end
  end
end