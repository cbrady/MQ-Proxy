require 'test_helper'

class MQProxyTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  
  data["Address"] = { "AdminArea1" => "US",
                      "AdminArea2" => "",
                      "AdminArea3" => "CO",
                      "AdminArea4" => "",
                      "AdminArea5" => "Denver",
                      "AdminArea6" => "",
                      "AdminArea7" => "",
                      "PostalCode" => "80203",
                      "Street" => "P+St"}
  
  data["AutoGeocodeCovSwitch"] = { "Name" => "mqgauto",
                                   "MaxMatches" => "0" }
  data["Authentication"] = {}
  
  test "the truth" do
    assert true
  end
end
