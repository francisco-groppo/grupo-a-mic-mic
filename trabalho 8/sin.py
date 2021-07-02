import time
import math

i = None
curTime = None
curTime2 = None


for j in range(5):
	i = 1
	curTime = time.ticks_ms()
	while i < 50000:
  		a = math.sin(i)
  		i += 1
	curTime2 = time.ticks_ms()
	print(curTime2 - curTime)