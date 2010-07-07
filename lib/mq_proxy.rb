# MQProxy

class MQProxy
    
  def initialize()
    @config_path = RAILS_ROOT + '/config/mq_proxy_config.yml'
  end
  
  def config_path
    return @config_path
  end
  
  def get_county(address = {})
    geo = XML::Document.string(geocode_address(address))
    return geo.root.find_first("LocationCollection").find_first("GeoAddress").find_first("AdminArea4").content
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
    source_geo = XML::Document.string(geocode_address(source))
    destination_geo = XML::Document.string(geocode_address(destination))
    addresses = generate_route_xml(source_geo,destination_geo)
    return route_addresses(addresses)
  end

  def get_lat_long(data = {}, options = {})
    res = XML::Document.string(geocode_address(data, options))
    return res.root.find_first("LocationCollection").find_first("GeoAddress").find_first("LatLng").to_a
  end

  
  def get_authentication
    return get_client_id, get_password
  end

  def get_client_id
    return YAML.load(ERB.new(File.read(@config_path)).result).symbolize_keys[:clientid].to_s
  end

  def get_password
    return YAML.load(ERB.new(File.read(@config_path)).result).symbolize_keys[:password]
  end
  
  def authenticate_xml_document(doc)
    root = doc.root
    clientId, password1 = get_authentication
    if clientId.blank? 
      errorString = "No clientid set in the proxy page"
      statusCode = "500"
      raise errorString
    end
    authentication = XML::Node.new("Authentication")
    authentication["Version"] = "2"
    clientid = XML::Node.new("ClientId")
    password = XML::Node.new("Password")
    clientid.content = "#{clientId}"
    password.content = password1 #"x9Z7A6z5" #password
    authentication << clientid
    authentication << password
    root << authentication
    return doc
  end
  
  def generate_route_xml(source, destination)
    doc = XML::Document.new
    doc.root = XML::Node.new('DoRoute')
    root = doc.root
    root['Version'] = '2'
    collection = XML::Node.new('LocationCollection')
    collection['Count'] = '2'
    root << collection
    collection << doc.import(source.root.first.first)
    collection << doc.import(destination.root.first.first)
    
    options = XML::Node.new('RouteOptions')
    options['Version'] = '3'
    root << options 
    
    doc = authenticate_xml_document doc
    
    return doc
  end
  
  def generate_geocode_xml(elements = {}) #:nodoc:
    doc = XML::Document.new()
    doc.root = XML::Node.new('Geocode')
    root = doc.root
    root["Version"] = "1"
    elements.each do |k,v|
      node = XML::Node.new(k)
      root << node
      v.each do |i,m|
        subnode = XML::Node.new(i)
        subnode.content = m 
        node << subnode
      end
    end

    doc = authenticate_xml_document doc
    
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
      # default url options for mapquest
      options[:method] ||= 'POST'
      options[:port] ||= 80
      options[:name] ||= 'route.free.mapquest.com'
      options[:path] ||= 'mq'

      xmlInputString = ''

     # this begin is the begin for rescue in the last which will handle all raise 
     begin  

       errorString = ""
       statusCode = ""
       
       xmlInputString = addresses.to_s

       url = "http://"+options[:name]+":"+options[:port].to_s+"/"+options[:path]+"/mqserver.dll?e=5"

       headers = {"Content-Type" => "text/xml; charset=utf-8"}

       Net::HTTP.start(options[:name], options[:port]) { |http|  
         http.request_post(url, xmlInputString,headers) {|response|
           strResp = ""
           response.read_body do |str|   # read body now
             strResp = strResp + str           
           end

           # return "#{response.code} #{response.message}" if response.code != 200
           return strResp
         } 
       }

     rescue Exception => msg
       if errorString == "" then
          errorString = "Connection cannot be established. #{msg}"
          statusCode = "404"
       else
          errorString = msg      
       end
       return "#{errorString} #{statusCode}"

     end 
  end

  def geocode_address(data = {}, options = {})
    # return if data is blank
    return "Please enter data" if data.blank?
    return "Please enter information for <Address>" if data["Address"].blank?

    # ensures that data is sent to mapquest in correct order
    mq_data = ActiveSupport::OrderedHash.new
    mq_data["Address"] = data["Address"]
    mq_data["AutoGeocodeCovSwitch"] = data["Address"]


    # default url options for mapquest
    options[:method] ||= 'POST'
    options[:port] ||= 80
    options[:name] ||= 'geocode.free.mapquest.com'
    options[:path] ||= 'mq'

    xmlInputString = ''

    doc = generate_geocode_xml mq_data

    xmlInputString = doc.to_s

    url = "http://"+options[:name]+":"+options[:port].to_s+"/"+options[:path]+"/mqserver.dll?e=5"

    headers = {"Content-Type" => "text/xml; charset=utf-8"}

    Net::HTTP.start(options[:name], options[:port]) { |http|  
      http.request_post(url, xmlInputString,headers) {|response|
        strResp = ""
        response.read_body do |str|   # read body now
          strResp = strResp + str           
        end
         
        return strResp
      } 
    }
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