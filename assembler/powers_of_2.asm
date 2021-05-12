# Powers of 2 sequence generator 

loop: # infinite... 
	LOAD a
  ADD b
  STORE b
  LOAD b
  STORE a
	JUMP loop

# variables 
.a 1
.b 1
.c 0
