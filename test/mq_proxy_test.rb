require './test_helper'

class MQProxyTest < Test::Unit::TestCase
  def setup
    @proxy = MQProxy.new
    @data = {:adminArea1 => "US",:adminArea2 => "",:adminArea3 => "NY",:adminArea4 => "",:adminArea5 => "Brooklyn",:adminArea6 => "",:adminArea7 => "",:postalCode => "11222",:street => "527 Leonard St."}
  end
  
  def test_get_geocode
    geocode = @proxy.geocode_address(@data)
    assert_equal(geocode.street,"527 Leonard St")
    assert_equal(geocode.city,"Brooklyn")
    assert_equal(geocode.state,"NY")
    assert_equal(geocode.county,"Kings County")
    assert_equal(geocode.zip,"11222-3262")
    assert_equal(geocode.country,"US")
    assert_equal(geocode.lat,40.72307)
    assert_equal(geocode.lng,-73.94939)
  end
  
  def test_get_route
    data2 = {:adminArea1 => "US",:adminArea2 => "",:adminArea3 => "NY",:adminArea4 => "",:adminArea5 => "Hastings on Hudson",:adminArea6 => "",:adminArea7 => "",:postalCode => "10706",:street => "603 Warburton Ave."}
    route = @proxy.get_route(@data,data2)
    assert_equal(route.time,2461)
    assert_equal(route.distance,24.2259998321533)
  end
end
