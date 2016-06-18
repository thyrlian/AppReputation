module AppReputation
  class Countries
    attr_reader :list
    
    def initialize(file)
      regex = /^[A-Z]{2}$/
      @list = []
      File.open(file, 'r') do |f|
        f.readlines.each do |l|
          @list.push(l.chomp) if regex.match(l)
        end
      end
      @list.uniq!
    end
    
    class << self
      def parse(filename)
        new(filename)
      end
    end
    
    def include?(*countries)
      list_unsupported_countries(*countries).empty?
    end
    
    def list_unsupported_countries(*countries)
      countries = countries.map { |country| country.upcase }.uniq
      countries - @list
    end
    
    private_class_method :new
  end
end
