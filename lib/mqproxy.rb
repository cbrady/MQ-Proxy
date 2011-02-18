# MQProxy - Collection of classes used to access the MapQuest API.
# Copyright (c) 2011 Christopher Brady
# Licensed under the same terms as Ruby. No warranty is provided

require 'json'
require 'net/http'

# Main class for MapQuest API calls 
class MQProxy
  # Get directions from one address to the other
  def get_route(source, destination, options = {})
    addresses = generate_route_json(source,destination, options[:mq_options])
    return MQProxyRoute.new(route_addresses(addresses,options))
  end
  
  # Get directions from one address to the other
  def geocode_address(address, options = {})
    doc = JSON.generate({:location => address, :options => options[:mq_options]})
    xmlInputString = doc.to_s
    return MQProxyGeocode.new(send_to_map_quest(xmlInputString, options))
  end
  
  private
    # Format JSON for MapQuest route call
    def generate_route_json(source, destination, options)
      doc = {:locations => [source, destination], :options => options}
      doc = JSON.generate(doc)
      return doc
    end
  
    # Append proper path and send to MapQuest
    def route_addresses(addresses, options)
      xmlInputString = addresses.to_s
      options[:path] ||= 'directions/v1/route'
      return send_to_map_quest(xmlInputString, options)
    end
  
    # Generic function to send data to MapQuest and handle response
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

# Class to handle MapQuest directions request response
class MQProxyRoute
  attr_accessor :time, :distance, :directions, :raw
  
  # Initialize MQProxyRoute and set standard data
  def initialize(route)
    @raw = route
    @time = extract_data('time')
    @distance = extract_data('distance')
    @directions = extract_data('legs')
  end
  
  private
  
    # Extract information from repsonse
    def extract_data(field)
      return @raw['route'][field]
    end
end

# Class to handle MapQuest geocode request response
class MQProxyGeocode
  attr_accessor :street, :city, :zip, :county, :state, :country, :lat, :lng, :raw
  
  # Initialize MQProxyGeocode and set standard data
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
  
  private
  
    # Extract information from repsonse
    def extract_data(field)
      @raw['results'].first['locations'].first[field]
    end
  
    # Extract latitude and longitude information from response
    def extract_lat_lng
      latLng = @raw['results'].first['locations'].first['latLng']
      return [latLng['lng'],latLng['lat']]
    end
end