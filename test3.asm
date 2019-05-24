.text

	addi $a0, $zero, 20
	jal init
	
	addi $a0, $zero, 16
	jal malloc
	
	#realloc no implementado
	
	addi $v0, $zero, 10	
	syscall
	

.include "memory-manager.asm"