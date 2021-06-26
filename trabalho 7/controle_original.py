from machine import Pin
import machine
import dht
import time
import math

temperature = None


dc_motor_pin_a = machine.Pin((5), machine.Pin.OUT)
dc_motor_pin_b = machine.Pin((4), machine.Pin.OUT)
dc_motor_pwm = machine.PWM((16))
dhts=dht.DHT11(machine.Pin((2)));dhts.measure();time.sleep(2)
while True:
  dhts.measure()
  temperature = dhts.temperature()
  if temperature > 26:
    dc_motor_pwm.duty((70 * math.log((temperature + 1) / 10)))
  else:
    dc_motor_pwm.duty(0)
  time.sleep(1)