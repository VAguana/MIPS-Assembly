
.macro func2()
	la $a0, debug
	addi $v0, $zero, 4
	syscall
.end_macro

func1:
	func2()
	jr $ra






.data
	debug: .asciiz "wtf \n"
	.globl debug