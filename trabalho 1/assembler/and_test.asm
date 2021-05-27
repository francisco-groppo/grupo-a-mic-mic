# Testing and instruction

loop: # infinite...
	LOAD a
  AND b
  STORE c
  LOAD c
  STORE a
  LOAD c
  STORE b
	JUMP loop

# variables 
.a 233
.b 222
.c 1
