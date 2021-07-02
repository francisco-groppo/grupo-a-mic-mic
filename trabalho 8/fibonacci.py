import time
import math

i = None
curTime = None
curTime2 = None


for j in range(5):
	i = 1
	k = 0
	curTime = time.ticks_ms()
	while k < 10000:
		k = k + 1
  		i += i
	curTime2 = time.ticks_ms()
	print(curTime2 - curTime)