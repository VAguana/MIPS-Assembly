
.text

	addi $a0, $zero, 500
	jal init
	#Creamos lista
	jal create
	move $s1, $v0 #guardamos la lista en s1
	
	addi $a0, $zero, 2
	jal newNumber

	addi $a1, $v0, 0
	addi $a0, $s1, 0
	jal insert

	addi $a0, $zero, 4
	jal newNumber
		
	addi $a1, $v0, 0
	addi $a0, $s1, 0
	jal insert
	
	addi $a0, $zero, 6
	jal newNumber
		
	addi $a1, $v0, 0
	addi $a0, $s1, 0
	jal insert
	
	addi $a0, $zero, 8
	jal newNumber
		
	addi $a1, $v0, 0
	addi $a0, $s1, 0
	jal insert	
		
	addi $a0, $zero, 10
	jal newNumber
		
	addi $a1, $v0, 0
	addi $a0, $s1, 0
	jal insert																							
	
	addi $a0, $zero, 12
	jal newNumber
		
	addi $a1, $v0, 0
	addi $a0, $s1, 0
	jal insert
	
	addi $a0, $zero, 14
	jal newNumber
		
	addi $a1, $v0, 0
	addi $a0, $s1, 0
	jal insert
	
	addi $a0, $zero, 16
	jal newNumber
		
	addi $a1, $v0, 0
	addi $a0, $s1, 0
	jal insert
	
	addi $a0, $zero, 18
	jal newNumber
		
	addi $a1, $v0, 0
	addi $a0, $s1, 0
	jal insert
	
	addi $a0, $zero, 20
	jal newNumber
		
	addi $a1, $v0, 0
	addi $a0, $s1, 0
	jal insert
	
	addi $a0, $s1, 0
	la $a1, fun_print
	jal print
	
	addi $v0, $zero, 10
	syscall
	

.include "linked-list.asm"
