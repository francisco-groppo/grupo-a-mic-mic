.macro imprime (%string)
	la a0, %string
	li a7, 4
	ecall
.end_macro

.text
	# generate number
	la a0, number
	li a1, 100
	li a7, 42
	ecall
	mv a4, a0
	
	# counter
	li a5, 0
	# print instructions
	imprime(instructions)
	j get_input

get_input:
	la a0, guess
	li a7, 5
	ecall
	j handle_input
	
handle_input:
	addi a5, a5, 1
	beq a0, a4, end
	bgt a0, a4, gt
	blt a0, a4, lt
	
end:
	imprime(guess_right)
	mv a0, a5
	li a7, 1
	ecall
	imprime(tentativas)
	li a7, 10
	ecall
	
gt:
	imprime(guess_less)
	j get_input

lt:
	imprime(guess_more)
	j get_input	
	
.data
instructions: .asciz "Tente adivinhar um número de 0 a 100\n"
string: .space 256
inverted_string: .space 256
number: .space 8
bound: .float 100
guess: .space 8
guess_less: .asciz "Tente um número menor\n"
guess_more: .asciz "Tente um número maior\n"
guess_right: .asciz "Parabéns, você acertou o número escolhido em "
tentativas: .asciz " tentativas!"