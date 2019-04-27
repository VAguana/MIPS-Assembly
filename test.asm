
.text

	addi $a0, $zero, 500
	jal init
	#Creamos lista
	jal create
	move $s1, $v0 #guardamos la lista en s1
	
	addi $a0, $zero, 1
	jal newNumber

	addi $a1, $v0, 0
	addi $a0, $s1, 0
	jal insert

	addi $a0, $zero, 2
	jal newNumber
		
	addi $a1, $v0, 0
	addi $a0, $s1, 0
	jal insert
	
	addi $a0, $zero, 3
	jal newNumber
		
	addi $a1, $v0, 0
	addi $a0, $s1, 0
	jal insert
	
	addi $a0, $zero, 4
	jal newNumber
		
	addi $a1, $v0, 0
	addi $a0, $s1, 0
	jal insert	
		
	addi $a0, $zero, 5
	jal newNumber
		
	addi $a1, $v0, 0
	addi $a0, $s1, 0
	jal insert																							
	
	addi $a0, $s1, 0
	la $a1, fun_print
	jal print
	
	addi $a0, $s1, 0
	addi $a1, $zero, 1
	jal delete
	
	addi $a0, $s1, 0
	addi $a1, $zero, 4
	jal delete
		
	addi $a0, $s1, 0
	la $a1, fun_print
	jal print
	
	addi $v0, $zero, 10
	syscall
	

.include "testLinkedList.asm"
