.text

	addi $a0, $zero, 20
	jal init
	
	addi $a0, $zero, 16
	jal malloc
	
	addi $a0, $zero, 8
	jal malloc

	addi $v0, $zero, 10	
	syscall


.include "memory-manager.asm"