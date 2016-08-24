require 'date'

module AppReputation
  class Installations
    attr_reader :date, :count
    
    def initialize(date, count)
      @date = Date.parse(date)
      @count = count
    end
    
    def ==(another_installations)
      if another_installations.respond_to?(:date) && another_installations.respond_to?(:count)
        return @date == another_installations.date && @count == another_installations.count
      else
        return false
      end
    end
  end
end
