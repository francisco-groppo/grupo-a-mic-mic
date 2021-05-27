# Testing conditional jump 

loop: # infinite... 
	LOAD a
  SUB b
  STORE a
	JUMP loop

# variables 
.a 5
.b 1
.c 1
