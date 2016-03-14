# run with
# rvmsudo ruby watcher.rb
#

require 'pi_piper'
load 'camera.rb'

# http://www.raspberrypi-spy.co.uk/2012/06/simple-guide-to-the-rpi-gpio-header-and-pins/#prettyPhoto
DOOR_PIN = 7
BUTTON_PIN = 8
SOUND_PIN = 18 # pwm

DEFAULT_SOUND_VALUE = 0.5

@pwm = PiPiper::Pwm.new pin: SOUND_PIN
@pwm.value = DEFAULT_SOUND_VALUE
@pwm.off

def beep(duration = 1, value = DEFAULT_SOUND_VALUE)
  @pwm.value = value
  @pwm.on
  sleep duration
  @pwm.off
end

PiPiper.watch pin: DOOR_PIN, pull: :up do |pin|
  puts "door #{pin.last_value} to #{pin.value}"
  beep
  Camera.enable
end

# pull up is much stronger, and we need additional pull up 500 ohm
PiPiper.watch pin: BUTTON_PIN do |pin|
  puts "button change #{pin.last_value} to #{pin.value}"
  beep 0.2, 0.2
  Camera.disable
end

puts "start"
(0..0.5).step(0.01).each do |value|
  beep 0.05, value
end
PiPiper.wait
puts "end"
