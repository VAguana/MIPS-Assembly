
.data

msg1:	.asciiz  "\n"
initHead: .word 0


.text
main:
	#print de prueba:
	la $a0 initHead
	li $v0  1
	syscall

	la $a0 msg1
	li $v0 4
	syscall

	addi $a0 $zero 4
	jal init
	
	#print de prueba:
	la $a0 initHead
	li $v0  4
	syscall
	
	jal end




init:
	#Se llama a init con los argumentos que hay en $a0
	li $v0, 9
	syscall
	
	sw $v0 initHead
	jr $ra

test:
	la $a0 msg1
	addi $v0 $zero 4
	syscall
	jr $ra
	
end:
	li $v0 10
	syscall