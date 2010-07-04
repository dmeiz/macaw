require 'test/helper'
require 'net/http'

class MacawTest < Test::Unit::TestCase
  include Macaw::Methods

  should "record a request to Google" do
    macaw("www.google.com", 80) do |host, port|
      resp = Net::HTTP.get(URI.parse("http://#{host}:#{port}/"))
      assert_match /Feeling Lucky/, resp
    end
  end
end
