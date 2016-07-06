module AppReputation
  class Ratings
    attr_reader :statistics
    
    def initialize(*statistics)
      # statistics start from one star to top stars
      begin
        are_params_valid = statistics.inject(true) do |result, x|
          result && (x.to_i == x)
        end
      rescue NoMethodError
        raise(ArgumentError, 'Ratings only accepts Integer values')
      end
      if are_params_valid
        @statistics = statistics
      else
        raise(ArgumentError, 'Ratings only accepts Integer values')
      end
    end
    
    def average
      gross = @statistics.each_with_index.inject(0) do |sum, (item, index)|
        # count is item
        # stars is index + 1
        sum + item * (index + 1)
      end
      if gross == 0
        return 0
      else
        return gross * 1.0 / @statistics.inject(:+)
      end
    end
    
    def ==(another_ratings)
      if another_ratings.respond_to?(:statistics)
        return @statistics == another_ratings.statistics
      else
        return false
      end
    end
    
    def +(another_ratings)
      return self if another_ratings.nil?
      if @statistics.size == another_ratings.statistics.size
        new_statistics = [@statistics, another_ratings.statistics].transpose.map { |x| x.inject(:+) }
        return self.class.new(*new_statistics)
      else
        raise(ArgumentError, 'Different types of ratings')
      end
    end
  end
end
