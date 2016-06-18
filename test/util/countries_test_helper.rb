module CountriesTestHelper
  def get_countries_from_stub_file(content_lines)
    countries = []
    file = MiniTest::Mock.new
    file.expect(:readlines, content_lines)
    File.stub(:join, file) do
      File.stub(:open, '', file) do
        countries = AppReputation::Countries.parse(file)
      end
    end
    countries
  end
end
