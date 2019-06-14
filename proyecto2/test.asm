#ARCHIVO DE PRUEBA



.text
	la $a0, PROGS
	
	
	jal instrumentar
	


	li $v0, 10
	syscall

.include "instrumentador.asm"	
