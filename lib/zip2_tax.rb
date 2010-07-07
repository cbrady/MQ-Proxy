class Zip2Tax
  
  def get_rate(zip)
    response = lookup(zip)
    doc = XML::Document.string(response)
    root = doc.root
    return root.find_first('rate').content.to_f
  end
  
  private
    def lookup(zip)
      url = "http://www.zip2tax.com/Link/<enter specialized path here>"
      password = "<enter password here>"
      url = url + "?pwd=" + password + "&zip=" + zip.to_s
    
      sname = "www.zip2tax.com"
      sport = 80
    
      Net::HTTP.start(sname, sport) {|http|
           http.request_get(url) {|response|
                 strResp = ""
                 response.read_body do |str|   # read body now
                   strResp = strResp + str 
                 end
                 return strResp       
           }
        }
    end
  
  
end