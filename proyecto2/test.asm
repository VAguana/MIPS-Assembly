#ARCHIVO DE PRUEBA



.text
	lw $a0, PROGS
	
	jal instrumentar
	


	li $v0, 10
	syscall

.include "instrumentador.asm"
.include "myprogstest.asm"
