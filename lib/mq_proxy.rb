# MQProxy
require 'json'
require 'net/http'

class MQProxy
  attr_reader :config_path  
  
  def initialize()
  end
  
  def get_route(source, destination, options = {})
    addresses = generate_route_json(source,destination, options[:mq_options])
    return @route = JSON.parse(route_addresses(addresses,options))
  end
  
  def get_distance
    return {:status => false, :error => "Route blank, please get a route."} if @route.nil?
    return @route['route']['distance']
  end
  
  def get_lat_lng(address, options ={})
    response = geocode_address(address, options)
    return response[:error] unless response[:status]
    doc = JSON.parse(response[:data])
    return doc['results'].first['locations'].first['latLng']
  end
  
  def geocode_address(address, options = {})
    # return if data is blank
    return {:status => false, :error => "Please enter an address"} if address.nil?

    doc = JSON.generate({:location => address, :options => options[:mq_options]})
    xmlInputString = doc.to_s
    return {:status => true, :data => send_to_map_quest(xmlInputString, options).body}
    
  end
  
  private
  
    def get_authentication
      return get_client_id, get_password
    end

    def get_client_id
      return YAML.load(File.open(@config_path))['clientid']
    end

    def get_password
      return YAML.load(File.read(@config_path))['password']
    end
    
    def get_app_key
      return YAML.load(File.read(@config_path))['appkey']
    end
  
    def generate_route_json(source, destination, options)
      doc = {:locations => [source, destination], :options => options}
      doc = JSON.generate(doc)
      return doc
    end
  
    def handle_response(response)
      case response
      when Net::HTTPSuccess then return MQProxySuccessResponse.new(response)
      when Net::HTTPClientError then return MQProxyNotFoundResponse.new(response)
      when Net::HTTPServerError then return MQProxyServerErrorResponse.new(response)
      else
        return false
      end
    end
  
    def route_addresses(addresses, options = {})

        xmlInputString = addresses.to_s
        
        options[:path] = 'directions/v1/route'
        return send_to_map_quest(xmlInputString, options).body

    end
  
    def send_to_map_quest(xmlInputString, options)
      # this begin is the begin for rescue in the last which will handle all raise 
      begin  

        errorString = ""
        statusCode = ""
      
        # default url options for mapquest
        options[:method] ||= 'POST'
        options[:port] ||= 80
        options[:name] ||= 'www.mapquestapi.com'
        options[:path] ||= 'geocoding/v1/address'
        
        url = URI.parse("http://"+options[:name]+"/"+options[:path] +"?key=#{APP_KEY}")
        headers = {"Content-Type" => "text/json; charset=utf-8"}
        http = Net::HTTP.new(url.host, url.port)
        # http.set_debug_output $stderr
        res = http.start {  
          http.post(url.request_uri ,xmlInputString,headers)
        }

      rescue Exception => msg
        if errorString == "" then
           errorString = "Connection cannot be established. #{msg}"
           statusCode = "404"
           raise 
        else
           errorString = msg      
        end
        return "#{errorString} #{statusCode}"

      end
    end
end

class MQProxyResponse
  attr_accessor :code, :message, :str_response
  def initialize(response)
    @code = response.code
    @message = response.message
    @str_response = ''
    response.read_body do |str|   # read body now
      @str_response = @str_response + str           
    end
  end
end

class MQProxySuccessResponse < MQProxyResponse
end

class MQProxyNotFoundResponse < MQProxyResponse
end

class MQProxyServerErrorResponse < MQProxyResponse
end