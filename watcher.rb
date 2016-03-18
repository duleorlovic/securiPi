# run with
# rvmsudo ruby watcher.rb
#

require 'pi_piper'
require 'ostruct'
load 'camera.rb'
load 'sound.rb'
load 's3.rb'

# http://www.raspberrypi-spy.co.uk/2012/06/simple-guide-to-the-rpi-gpio-header-and-pins/#prettyPhoto
DOOR_PIN = 7
BUTTON_PIN = 8
SOUND_PIN = 18 # pwm
TIMEOUT = 2
VIDEO_LENGTH = 5000

sound = Sound.new sound_pin: SOUND_PIN
camera = Camera.new
state = OpenStruct.new isActive: false

puts "Start #{Time.now} start.pid=#{$$} isActive=#{state.isActive}"
File.open('start.pid','w') { |file| file.write($$) }

# when door is opened it connects the ground value=0
# when is closed (switch is no active) it is disconnected from ground value=1
# noise could affect when door is closed with temporary =>0
PiPiper.watch pin: DOOR_PIN, pull: :up do |pin|
  puts "#{Time.now} door #{pin.last_value} to #{pin.value}"
  sleep 0.1
  pin.read
  if pin.value == 1
    puts "Noise since value=#{pin.value}" 
  else
    if state.isActive
      puts "value=0 isActive=true DOOR OPENED"
      TIMEOUT.times do |i|
        break unless state.isActive
        sleep 2
        sound.beep 0.2
        if i == TIMEOUT-1
          camera.enable
          system "raspivid -o vid.h264 -t #{VIDEO_LENGTH}"
          S3.upload 'vid.h264'
          camera.disable
          sound.beep 2
        else
          print i
        end
      end
    else
      puts "isActive=false"
    end
  end
end

# pull up is much stronger, and we need additional pull up 500 ohm
# when button is pressed it connects to ground
PiPiper.watch pin: BUTTON_PIN, trigger: :falling do |pin|
  puts "#{Time.now} button change #{pin.last_value} to #{pin.value}"
  sound.beep 0.2, 0.2
  sleep 0.5
  pin.read
  if pin.value == 0
    puts "long button #{pin.last_value} to #{pin.value}"
    state.isActive = true
    sound.activate
  else
    puts "short button #{pin.last_value} to #{pin.value}"
    state.isActive = false
    sound.deactivate
  end
end

sound.up_sound
PiPiper.wait
puts "end"
