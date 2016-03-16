# run with
# rvmsudo ruby watcher.rb
#

require 'pi_piper'
load 'camera.rb'
load 'sound.rb'

# http://www.raspberrypi-spy.co.uk/2012/06/simple-guide-to-the-rpi-gpio-header-and-pins/#prettyPhoto
DOOR_PIN = 7
BUTTON_PIN = 8
SOUND_PIN = 18 # pwm

puts "Start #{Time.now} start.pid=#{$$}"
File.open('start.pid','w') { |file| file.write($$) }

sound = Sound.new sound_pin: SOUND_PIN
camera = Camera.new

# when door is opened it disconnects the ground
PiPiper.watch pin: DOOR_PIN, pull: :up do |pin|
  puts "#{Time.now} door #{pin.last_value} to #{pin.value}"
  sleep 0.1
  pin.read
  if pin.value == 1
    puts "Noice since last_value=#{pin.last_value} value=#{pin.value}"
  else
    puts "DOOR OPENED"
    sleep 5
    # puts some delay so you can disable alarm
    sound.beep
    camera.enable
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
    camera.enable ? sound.activate : sound.error
  else
    puts "short button #{pin.last_value} to #{pin.value}"
    camera.disable ? sound.deactivate : sound.error
  end
end

sound.up_sound
PiPiper.wait
puts "end"
