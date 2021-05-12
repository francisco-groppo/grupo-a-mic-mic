# Testing conditional jump 

loop: # infinite... 
	LOAD a
  ADD b
  STORE b
  LOAD b
  STORE a
	JUMP loop
  LOAD a
  ADD b
  ADD b
  ADD b
  STORE a
  JUMP loop

# variables 
.a 0
.b 1
.c 0
