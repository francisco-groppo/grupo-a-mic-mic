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
	la a3, uppercase_string
	
# loop and add to a3
loop:
	lb a4, 0(a0)
	li a6, 10
	beq a4, a6, end
	li a6, 97
	blt a4, a6, out_of_bounds
	li a6, 128
	bgt a4, a6, out_of_bounds
	addi a4, a4, -32
	sb a4, 0(a3)
	addi a3, a3, 1
	addi a0, a0, 1
	j loop

# validation for not letters or already uppercase letter
out_of_bounds:
	sb a4, 0(a3)
	addi a3, a3, 1
	addi a0, a0, 1
	j loop

end:
	imprime(uppercase_intro)
	imprime(uppercase_string)
	
.data
what: .asciz "Insert a string\n"
uppercase_intro: .asciz "Your string in uppercase is: "
string: .space 256
uppercase_string: .space 256