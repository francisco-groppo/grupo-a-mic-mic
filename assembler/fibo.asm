# Fibonacci sequence generator 

loop: # infinite... 
	LOAD a
	ADD b
	STORE c
	LOAD b
	STORE a
	LOAD c
	STORE b
	JUMP loop

# variables 
.a 0
.b 1
.c 0
