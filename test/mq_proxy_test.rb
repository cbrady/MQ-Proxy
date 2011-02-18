require 'test_helper'

class MQProxyTest < Test::Unit::TestCase
  def setup
    @proxy = MQProxy.new
    @data = {}

    @data = {"adminArea1" => "US",
                        "adminArea2" => "",
                        "adminArea3" => "NY",
                        "adminArea4" => "",
                        "adminArea5" => "Brooklyn",
                        "adminArea6" => "",
                        "adminArea7" => "",
                        "postalCode" => "11222",
                        "street" => "527 Leonard St"}
  end
  
  def test_get_route
    data2 = {}

    data2 = {"adminArea1" => "US",
                        "adminArea2" => "",
                        "adminArea3" => "MT",
                        "adminArea4" => "",
                        "adminArea5" => "Big Sky",
                        "adminArea6" => "",
                        "adminArea7" => "",
                        "postalCode" => "59716",
                        "street" => "1 Lone Mountain Trail"}
    
    route = @proxy.get_route(@data,data2)
    assert_equal(2215.996826171875,@proxy.get_distance)
  end
  
  def test_get_lat_lng
    lat_lng = @proxy.get_lat_lng(@data)
    assert_equal({"lng"=>-73.94939, "lat"=>40.72307},lat_lng)
  end
end
