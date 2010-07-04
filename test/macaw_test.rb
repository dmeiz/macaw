require 'test/helper'
require 'net/http'

class MacawTest < Test::Unit::TestCase
  include Macaw::Methods

  should "record a request to Google" do
    macaw "google" do
      resp = Net::HTTP.get(URI.parse("http://www.google.com/"))
      assert_match /Feeling Lucky/, resp
    end
  end
end
