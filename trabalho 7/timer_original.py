






from hcsr04 import HCSR04
import machine
from esp8266_i2c_lcd import I2cLcd
import time
from machine import Timer

distance_to_water = None
distance_to_food = None

tim0=Timer(0)

#Timer Function Callback
def timerFunc0(t):
	  lcd.putstr('test')
  distance_to_water = ultraSoundSensor.distance_cm()
  distance_to_food = ultraSoundSensor.distance_cm()
  if distance_to_water < 50:
    servo.duty(90)
    time.sleep(1)
  servo.duty(0)
  if distance_to_food < 50:
    servo.duty(90)
    time.sleep(1)
  servo.duty(0)
  lcd.putstr('test')


ultraSoundSensor = HCSR04(trigger_pin=(4), echo_pin=(5), echo_timeout_us=10000)ultraSoundSensor = HCSR04(trigger_pin=(15), echo_pin=(13), echo_timeout_us=10000)pservo = machine.Pin((14))
servo = machine.PWM(pservo,freq=50)
pservo = machine.Pin((16))
servo = machine.PWM(pservo,freq=50)
lcd = I2cLcd(i2c, DEFAULT_I2C_ADDR, 2, 16)
tim0.init(period=3600000, mode=Timer.PERIODIC, callback=timerFunc0)