import time
interactions = 1000

x = 10000000
pi = 10000000
curtime = time.ticks_ms()
for i in range(1, interactions):
  x *= -1
  pi += x/(2*i + 1)
  
pi = 4*pi/10000000
curtime2 = time.ticks_ms()
print("Iterations: " + str(interactions))
print("Time (ms) took: " + str((curtime2 - curtime)))
print("Value obtained: " + str(pi))
print("------")

  
interactions = 5000

x = 10000000
pi = 10000000
curtime = time.ticks_ms()
for i in range(1, interactions):
  x *= -1
  pi += x/(2*i + 1)
  
pi = 4*pi/10000000
curtime2 = time.ticks_ms()
print("Iterations: " + str(interactions))
print("Time (ms) took: " + str((curtime2 - curtime)))
print("Value obtained: " + str(pi))
print("------")


interactions = 50000

x = 10000000
pi = 10000000
curtime = time.ticks_ms()
for i in range(1, interactions):
  x *= -1
  pi += x/(2*i + 1)
  
pi = 4*pi/10000000
curtime2 = time.ticks_ms()
print("Iterations: " + str(interactions))
print("Time (ms) took: " + str((curtime2 - curtime)))
print("Value obtained: " + str(pi))
print("------")


interactions = 500000

x = 10000000
pi = 10000000
curtime = time.ticks_ms()
for i in range(1, interactions):
  x *= -1
  pi += x/(2*i + 1)
  
pi = 4*pi/10000000
curtime2 = time.ticks_ms()
print("Iterations: " + str(interactions))
print("Time (ms) took: " + str((curtime2 - curtime)))
print("Value obtained: " + str(pi))
print("------")


interactions = 10000000

x = 10000000
pi = 10000000
curtime = time.ticks_ms()
for i in range(1, interactions):
  x *= -1
  pi += x/(2*i + 1)
  
pi = 4*pi/10000000
curtime2 = time.ticks_ms()
print("Iterations: " + str(interactions))
print("Time (ms) took: " + str((curtime2 - curtime)))
print("Value obtained: " + str(pi))