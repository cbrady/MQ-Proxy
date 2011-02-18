# MQProxy
require 'json'
require 'net/http'

class MQProxy
  def get_route(source, destination, options = {})
    addresses = generate_route_json(source,destination, options[:mq_options])
    return MQProxyRoute.new(route_addresses(addresses,options))
  end
  
  def geocode_address(address, options = {})
    return {:status => false, :error => "Please enter an address"} if address.nil?
    doc = JSON.generate({:location => address, :options => options[:mq_options]})
    xmlInputString = doc.to_s
    return MQProxyGeocode.new(send_to_map_quest(xmlInputString, options))
  end
  
  private
  
    def generate_route_json(source, destination, options)
      doc = {:locations => [source, destination], :options => options}
      doc = JSON.generate(doc)
      return doc
    end
  
    def route_addresses(addresses, options)
        xmlInputString = addresses.to_s
        options[:path] ||= 'directions/v1/route'
        return send_to_map_quest(xmlInputString, options)
    end
  
    def send_to_map_quest(xmlInputString, options)
      options[:method] ||= 'POST'
      options[:port] ||= 80
      options[:name] ||= 'www.mapquestapi.com'
      options[:path] ||= 'geocoding/v1/address'
      url = URI.parse("http://"+options[:name]+"/"+options[:path] +"?key=#{APP_KEY}")
      headers = {"Content-Type" => "text/json; charset=utf-8"}
      http = Net::HTTP.new(url.host, url.port)
      json ||= begin
        response = http.start {  
          http.post(url.request_uri ,xmlInputString,headers)
        }
        doc = JSON.parse(response.body)
        if doc['info']['statuscode'] != 0
          raise StandardError, "There was an error with your request: #{doc['info']['message']}"
        end
        doc
      end
    end
end

class MQProxyRoute
  attr_accessor :time, :distance, :directions, :raw
  def initialize(route)
    @raw = route
    @time = extract_data('time')
    @distance = extract_data('distance')
    @directions = extract_data('legs')
  end
  
  def extract_data(field)
    return @raw['route'][field]
  end
end

class MQProxyGeocode
  attr_accessor :street, :city, :zip, :county, :state, :country, :lat, :lng, :raw
  def initialize(geocode)
    @raw = geocode
    @street = extract_data('street')
    @city = extract_data('adminArea5')
    @zip = extract_data('postalCode')
    @county = extract_data('adminArea4')
    @state = extract_data('adminArea3')
    @country = extract_data('adminArea1')
    @lng,@lat = extract_lat_lng
  end
  
  def extract_data(field)
    @raw['results'].first['locations'].first[field]
  end
  
  def extract_lat_lng
    latLng = @raw['results'].first['locations'].first['latLng']
    return [latLng['lng'],latLng['lat']]
  end
end