# run with
# rvmsudo ruby watcher.rb
#

require 'pi_piper'
require 'ostruct'
load 'camera.rb'
load 'sound.rb'
load 's3.rb'
load 'mail.rb'

# http://www.raspberrypi-spy.co.uk/2012/06/simple-guide-to-the-rpi-gpio-header-and-pins/#prettyPhoto
# model B revision 2.0
DOOR_PIN = 7
BUTTON_PIN = 8
SOUND_PIN = 18 # pwm
VIDEO_LENGTH = 6000
BIT_RATE = 4_000_000 # default is 17_000_000

sound = Sound.new sound_pin: SOUND_PIN
camera = Camera.new
state = OpenStruct.new isActive: true

puts "Start #{Time.now} start.pid=#{$$} isActive=#{state.isActive}"
File.open('start.pid','w') { |file| file.write($$) }

# when door is opened it connects the ground value=0
# when is closed (switch is no active) it is disconnected from ground value=1
# noise could affect when door is closed with temporary =>0
# so we add small capacitor 100nF
PiPiper.watch pin: DOOR_PIN, pull: :up do |pin|
  last_value = pin.last_value
  current_value = pin.value
  sleep 0.1
  pin.read
  test_value = pin.value
  if test_value == 1
    puts "#{Time.now} door noise last_value=#{last_value} current_value=#{current_value} test_value=#{test_value}"
  else
    if state.isActive
      puts "#{Time.now} door OPENED because isActive=#{state.isActive} and test_value=#{test_value} (last_value=#{last_value} current_value=#{current_value})"
      puts "value=0 isActive=true DOOR OPENED recording video"
      image_file = "temp/" + Time.now.to_s.tr(' ','_').tr(':','-').tr('+','-') + ".jpg"
      system "raspistill -o #{image_file} -vf -hf -w 300 -h 300 -ex night"
      video_file = "temp/" + Time.now.to_s.tr(' ','_').tr(':','-').tr('+','-') + ".h264"
      system "raspivid -o #{video_file} -vf -hf -t #{VIDEO_LENGTH} -b #{BIT_RATE} -ex night &"
      timeout = VIDEO_LENGTH / 1000
      timeout.times do |i|
        break unless state.isActive
        sleep 2
        sound.beep 0.2
        if i == timeout-1
          camera.enable
          MyMail.send attachment: image_file, text: S3.getUrl(video_file)
          S3.upload video_file
          camera.disable
          puts "Disable motion"
          sound.beep 2
        else
          print i
        end
      end
      system "rm #{video_file}" unless state.isActive
      system "rm #{image_file}" unless state.isActive
    else
      # puts "isActive=false"
    end
  end
end

# pull up is much stronger, and we need external pull up 500 ohm
# when button is pressed it connects to ground
PiPiper.watch pin: BUTTON_PIN, trigger: :falling do |pin|
  puts "#{Time.now} button change #{pin.last_value} to #{pin.value}"
  sound.beep 0.2, 0.2
  sleep 0.5
  pin.read
  if pin.value == 0
    puts "long button #{pin.last_value} to #{pin.value} isActive=TRUE"
    3.times do
      sound.beep
      sleep 2
    end
    state.isActive = true
    sound.activate
  else
    puts "short button #{pin.last_value} to #{pin.value} isActive=FALSE"
    state.isActive = false
    sound.deactivate
    camera.disable
  end
end

sound.up_sound
PiPiper.wait
puts "end"
