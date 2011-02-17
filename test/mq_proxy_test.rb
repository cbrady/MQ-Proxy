require './test_helper'

class MQProxyTest < ActiveSupport::TestCase

  
  config_path = '../config/mq_proxy_config.yml'
    
  data = {}

  data["Address"] = { "adminArea1" => "US",
                      "adminArea2" => "",
                      "adminArea3" => "MT",
                      "adminArea4" => "",
                      "adminArea5" => "Big Sky",
                      "adminArea6" => "",
                      "adminArea7" => "",
                      "postalCode" => "59716",
                      "street" => "1 Lone Mountain Trail"}
          

  data["AutoGeocodeCovSwitch"] = { "Name" => "mqgauto",
                                   "MaxMatches" => "0" }
  data["Authentication"] = {}
  
  
  geo_response = "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?><GeocodeResponse><LocationCollection Count=\"1\"><GeoAddress><AdminArea1>US</AdminArea1><AdminArea3>MT</AdminArea3><AdminArea4>Gallatin County</AdminArea4><AdminArea5>Bozeman</AdminArea5><PostalCode>59718-7125</PostalCode><Street>1 Stubbs Ln</Street><LatLng><Lat>45.729210</Lat><Lng>-111.094019</Lng></LatLng><ResultCode>L1CAB</ResultCode><GEFID>98985196</GEFID><SourceId>navt</SourceId></GeoAddress></LocationCollection></GeocodeResponse>"

  test "Should get config path" do
    proxy = MQProxy.new(config_path)
    assert_equal(proxy.config_path,config_path)
  end

  test "Should get county" do
    proxy = MQProxy.new(config_path)
    # proxy.stubs(:send_to_map_quest).returns(geo_response)
    county = proxy.get_county(data)
    assert_equal('Gallatin County', county)
  end
  
  test "Should get route" do
    data2 = {}

    data2["Address"] = { "adminArea1" => "US",
                        "adminArea2" => "",
                        "adminArea3" => "NY",
                        "adminArea4" => "",
                        "adminArea5" => "Brooklyn",
                        "adminArea6" => "",
                        "adminArea7" => "",
                        "postalCode" => "11222",
                        "street" => "527 Leonard St"}

    data2["AutoGeocodeCovSwitch"] = { "Name" => "mqgauto",
                                     "MaxMatches" => "0" }
    data2["Authentication"] = {}
    
    proxy = MQProxy.new(config_path)
    route = proxy.get_route(data,data2)
    
  end
end
