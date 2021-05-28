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
	
# find last char
find_end:
	lb a4, 0(a0)
	beq a4, zero, invert_begin
	
	li a6, 97
	blt a4, a6, out_of_bounds_less
	
	li a6, 122
	bgt a4, a6, out_of_bounds_greater
	
	addi a4, a4, -32
	sb a4, 0(a3)
	addi a3, a3, 1
	addi a0, a0, 1
	j find_end
	
# validations for not lowercase letters
out_of_bounds_less:
	li a6, 65
	bgt a4, a6, greater_min_upper
	addi a0, a0, 1
	j find_end
	
out_of_bounds_greater:
	li a6, 90
	blt a4, a6, less_max_upper
	addi a0, a0, 1
	j find_end
	
greater_min_upper:
	li a6, 90
	blt a4, a6, is_upper
	addi a0, a0, 1
	j find_end
	
less_max_upper:
	li a6, 65
	bgt a4, a6, is_upper
	addi a0, a0, 1
	j find_end
	
is_upper:
	sb a4, 0(a3)
	addi a3, a3, 1
	addi a0, a0, 1
	j find_end
	
# load data to begin loop
invert_begin:
	la a5, inverted_string
	la a6, string
	addi a3, a3, -1
	j invert_loop
	
# begin loop
invert_loop:
	lb a4, 0(a3)
	sb a4, 0(a5)
	addi a5, a5, 1
	addi a3, a3, -1
	bne a3, a6, invert_loop
	
	li a4, 10
	sb a4, 0(a5)
	j end
	
end:
	la a3, uppercase_string
	la a5, inverted_string
	j loop_compare
	
loop_compare:
	lb a2, 0(a3)
	lb a4, 0(a5)
	addi a5, a5, 1
	addi a3, a3, 1
	bne a2, a4, not_equal_jump
	beq a2, zero, is_equal
	j loop_compare

not_equal_jump:
	imprime(equal_intro)
	imprime(newline)
	imprime(string)
	imprime(not_equal)
	li a7, 10
	ecall
	
is_equal:
	imprime(equal_intro)
	imprime(newline)
	imprime(string)
	imprime(equal_conclusion)
	li a7, 10
	ecall
	
.data
newline: .asciz  "\n"
what: .asciz "Insira uma string\n"
equal_intro: .asciz "A string inserida \""
equal_conclusion: .asciz "\" é um palíndromo"
not_equal: .asciz "\" não é um palíndromo"
string: .space 256
uppercase_string: .space 256
inverted_string: .space 256
