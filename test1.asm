.text

	#Usamos malloc sin realizar previamente un init
	addi $a0, $zero, 2
	jal malloc
	
	
	#Creamos lista sin inicializar el manejador
	#jal create
	#move $s1, $v0 #guardamos la lista en s1
	
	addi $v0, $zero, 10	
	syscall
	

.include "linked-list.asm"
