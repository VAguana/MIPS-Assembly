.text

	addi $a0, $zero, 32
	jal init
	
	addi $a0, $zero, 8
	jal malloc
	
	addi $a0, $zero, 4
	jal malloc
	
	#realloc no implementado
	
	addi $a0, $zero, 8
	jal malloc
	
	addi $v0, $zero, 10	
	syscall
	

.include "memory-manager.asm"