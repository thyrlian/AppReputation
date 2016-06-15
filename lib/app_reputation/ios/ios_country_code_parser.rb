module AppReputation
  class IosCountryCodeParser
    class << self
      def parse(filename)
        regex = /^[A-Z]{2}$/
        countries = []
        file = File.join(File.dirname(__FILE__), filename)
        File.open(file, 'r') do |f|
          f.readlines.each do |l|
            countries.push(l.chomp) if regex.match(l)
          end
        end
        return countries
      end
    end
    
    private_class_method :new
  end
end
