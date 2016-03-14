require 'uri'
require 'net/http'

module Camera
  CAMERA_URL = "http://192.168.0.3"
  CAMERA_AUTHORIZATION = ENV["CAMERA_AUTHORIZATION"]

  def self.camera(enable = true)
    #uri_str = "http://192.168.0.3/form/enet?enet_source=md.asp&enet_avs_md_enable=No"
    uri_str = CAMERA_URL + "/form/enet"
    if enable
      puts "Enabling camera"
      enable_param = 'Yes'
    else
      puts "Disabling camera"
      enable_param = 'No'
    end
    params = {
      enet_source: 'md.asp',
      enet_avs_md_enable: enable_param,
    }
    uri = URI(uri_str)
    uri.query = URI.encode_www_form(params)

    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Basic #{CAMERA_AUTHORIZATION}"
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
    if res.class == Net::HTTPFound
      puts "Done"
    else
      puts res.body
    end
  end

  def self.enable
    camera(true)
  end

  def self.disable
    camera(false)
  end
end

