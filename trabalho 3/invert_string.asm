.macro imprime (%string)
	la a0, %string
	li a7, 4
	ecall
.end_macro

.text
	# print question
	la a0, what
	li a7, 4
	ecall
	# read the string
	la a0, string
	li a1, 255
	li a7, 8
	ecall
	
# find last char
find_end:
	lb a4, 0(a0)
	beq a4, zero, invert_begin
	addi a0, a0, 1
	j find_end
	
# load data to begin loop
invert_begin:
	la a3, inverted_string
	la a5, string
	addi a0, a0, -1
	j invert_loop
	
# begin loop
invert_loop:
	addi a0, a0, -1
	lb a4, 0(a0)
	sb a4, 0(a3)
	addi a3, a3, 1
	bne a0, a5, invert_loop
	
	li a4, 10
	sb a4, 0(a3)
	j end
	
end:
	imprime(inverted_intro)
	imprime(inverted_string)
	
.data
what: .asciz "Insert a string\n"
inverted_intro: .asciz "Your string inverted is: "
string: .space 256
inverted_string: .space 256
