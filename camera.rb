# Camera
#
# ruby -e "load 'camera.rb';c=Camera.new;c.disable"
# 
require 'uri'
require 'net/http'
require 'ostruct'

class Camera
  CAMERA_URL = "http://192.168.0.3"
  CAMERA_AUTHORIZATION = ENV["rvm_CAMERA_AUTHORIZATION"]

  attr_accessor :state

  def initialize
    @state = false
  end

  def enable
    change_state(true)
  end

  def disable
    change_state(false)
  end

  def enabled?
    state
  end

  def disabled?
    !state
  end

  def enabled!
    @state = true
  end

  def disabled!
    @state = false
  end

  private

  def change_state(enable = true)
    #uri_str = "http://192.168.0.3/form/enet?enet_source=md.asp&enet_avs_md_enable=No"
    uri_str = CAMERA_URL + "/form/enet"
    if enable
      puts "Enabling camera"
      enable_param = 'Yes'
    else
      puts "Disabling camera"
      enable_param = 'No'
    end
    #  puts "Already " + (enable ? 'enabled' : 'disabled')
    params = {
      # enet_source: 'md.asp',
      # enet_avs_md_enable: enable_param,
      enet_source: 'schedule.asp',
      enet_avs_mail_schdule_enable: enable_param,
    }
    uri = URI(uri_str)
    uri.query = URI.encode_www_form(params)

    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Basic #{CAMERA_AUTHORIZATION}"
    begin
      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
    # http://stackoverflow.com/questions/5370697/what-s-the-best-way-to-handle-exceptions-from-nethttp
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::OpenTimeout, Errno::EHOSTUNREACH,
       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
       res = OpenStruct.new body: e.message
    end
    if res.class == Net::HTTPFound
      if enable
        enabled!
      else
        disabled!
      end
      true
    else
      puts res.body
      false
    end
  end
end

