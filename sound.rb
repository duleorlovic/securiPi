require 'pi_piper'
DEFAULT_SOUND_VALUE = 0.5
class Sound
  attr_accessor :pwm
  def initialize(sound_pin: 8)
    @pwm = PiPiper::Pwm.new pin: sound_pin
    pwm.value = DEFAULT_SOUND_VALUE
    pwm.off
  end

  def beep(duration_in_sec = 1, value = DEFAULT_SOUND_VALUE)
    pwm.value = value
    pwm.on
    sleep duration_in_sec
    pwm.off
  end

  # beep beep
  def activate
    pwm.on
    sleep 0.5
    pwm.off
    sleep 0.3
    pwm.on
    sleep 0.5
    pwm.off
  end

  def deactivate
    pwm.value = 0.1
    pwm.on
    sleep 0.5
    pwm.off
  end

  def error
    5.times do
      @pwm.value = 0.5
      @pwm.on
      sleep 0.2
      @pwm.off
      @pwm.value = 0.1
      @pwm.on
      sleep 0.2
      @pwm.off
    end
  end

  def up_sound
    (0..0.5).step(0.03).each do |value|
      beep 0.05, value
    end
  end
end
