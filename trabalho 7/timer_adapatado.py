#from hcsr04 import HCSR04
import machine
import time
from machine import Timer

angle = None
distance_to_water = None
distance_to_food = None

tim0=Timer(0)

#Timer Function Callback
def timerFunc0(t):
  print('Iniciando sistema')
  #distance_to_water = ultraSoundSensor_food.distance_cm()
  #distance_to_food = ultraSoundSensor_water.distance_cm()
  if distance_to_water < 50:
	  print('Water motor on')
    #servo_water.duty(90)
	  time.sleep(1)
  #servo_water.duty(0))
  print('Water motor off')
  if distance_to_food < 50:
	  print('Food motor on')
	  time.sleep(1) 
    #servo_food.duty(90)
  #servo_food.duty(0)
  print('Food motor off')
  print('Concluindo')


#ultraSoundSensor_food = HCSR04(trigger_pin=(4), echo_pin=(5), echo_timeout_us=10000)
#ultraSoundSensor_water = HCSR04(trigger_pin=(15), echo_pin=(13), echo_timeout_us=10000)
#pservo_food = machine.Pin((14))
#servo_food = machine.PWM(pservo_food,freq=50)
#pservo_water = machine.Pin((16))
#servo_water = machine.PWM(pservo_water,freq=50)
#lcd = I2cLcd(i2c, DEFAULT_I2C_ADDR, 2, 16)
#angle = 0
distance_to_water = 35
distance_to_food = 60
tim0.init(period=5000, mode=Timer.PERIODIC, callback=timerFunc0)
time.sleep(6)
distance_to_water = 60
distance_to_food = 45
time.sleep(6)
distance_to_water = 60
distance_to_food = 51
time.sleep(6)
distance_to_water = 39
distance_to_food = 22
time.sleep(6)
tim0.deinit()