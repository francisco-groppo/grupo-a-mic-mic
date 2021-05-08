# Fibonacci sequence de-generator 

loop: # infinite... 
	LOAD b
	SUB a
	STORE c
	LOAD a
	STORE b
	LOAD c
	STORE a
	JUMP loop

# variables 
.a 144
.b 233
.c 0
