from machine import Pin
import machine
import dht
import time
import math

temperature = None
speed = None
temps = [10, 15, 20, 25, 26, 27, 30, 28, 27, 26, 25]
i = 0

# dc_motor_pin_a = machine.Pin((5), machine.Pin.OUT)
# dc_motor_pin_b = machine.Pin((4), machine.Pin.OUT)
# dc_motor_pwm = machine.PWM((16))
dhts=dht.DHT11(machine.Pin((2)));dhts.measure();time.sleep(2)
while i < len(temps):
  temperature = temps[i]
  # dhts.measure()
  # temperature = dhts.temperature()
  if temperature > 26:
    speed = (70 * math.log((temperature + 1) / 10))
    #dc_motor_pwm.duty((70 * math.log((temperature + 1) / 10)))
  else:
    speed = 0
    #dc_motor_pwm.duty(0)
  print('Rotation speed: ' + str(speed))
  i+=1
  time.sleep(1)