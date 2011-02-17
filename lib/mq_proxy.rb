# MQProxy

class MQProxy
  attr_reader :config_path  
  
  def initialize(config_path)
    @config_path = config_path || RAILS_ROOT + '/config/mq_proxy_config.yml'
  end
  
  def get_county(address = {})
    status, response = geocode_address(address)
    return string unless status
    geo = JSON.parse(response)
    return geo['results'][0]['locations'][0]['adminArea4']
  end
  
  def get_distance(route = '')
    return false if route.blank?
    
    doc = XML::Document.string(route)
    root = doc.root
    maneuvers = root.first.find_first('TrekRoutes').find_first('TrekRoute').find_first('Maneuvers')
    total = 0.0
    maneuvers.each do |maneuver|
      total += maneuver.find_first('Distance').content.to_f
    end
    return total
  end
  
  def get_route(source = {}, destination = {}, options = {})
    status, string = geocode_address(source, options)
    return string unless status
    source_geo = JSON.parse(string)['results'][0]['locations'][0]
    status, string = geocode_address(destination, options)
    return string unless status
    destination_geo = JSON.parse(string)['results'][0]['locations'][0]
    addresses = generate_route_json(source_geo,destination_geo)
    return route_addresses(addresses)
  end
  
  def get_lat_long(data = {}, options = {})
    status, string = geocode_address(data, options)
    return string unless status
    res = XML::Document.string(string)
    return res.root.find_first("LocationCollection").find_first("GeoAddress").find_first("LatLng").to_a
  end
  
  def geocode_address(data = {}, options = {})
    # return if data is blank
    return false, "Please enter data" if data.blank?
    return false, "Please enter information for <Address>" if data["Address"].blank?

    doc = JSON.generate({:location => data['Address']})
    xmlInputString = doc.to_s
    return true, send_to_map_quest(xmlInputString, options = {}).body
    
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
  
    def generate_route_json(source, destination)
      doc = {:locations => [source, destination]}
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
      
        return send_to_map_quest(xmlInputString, options)

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
        
        url = URI.parse("http://"+options[:name]+"/"+options[:path] +"?key=#{get_app_key}")
        headers = {"Content-Type" => "text/xml; charset=utf-8"}
        http = Net::HTTP.new(url.host, url.port)
        http.set_debug_output $stderr
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