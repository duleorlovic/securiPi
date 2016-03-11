require 'pi_piper'
include PiPiper

watch pin: 23 do
  puts "change #{last_value} #{value}"
end

pin = PiPiper::Pin.new(pin: 17, direction: :out)
pin.on
sleep 1
pin.off

PiPer.wait
