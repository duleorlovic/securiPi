# run with
# rvmsudo ruby watcher.rb
#

require 'pi_piper'

puts "start"
pwm = PiPiper::Pwm.new pin: 18
pwm.value = 0.5

PiPiper.watch pin: 17, pull: :up do |pin|
  puts "change #{pin.last_value} to #{pin.value}"
  pwm.on
  sleep 1
  pwm.off
end

PiPiper.wait
puts "end"
