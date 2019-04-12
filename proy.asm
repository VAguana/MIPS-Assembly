.data
	msg: 		.asciiz "Ingrese la memoria a reservar (bytes): "
	msg1:		.asciiz  "\n"
	error_init:	.asciiz "Error. La memoria solicitada supera el almacenamiento del heap"

	heapsize:	.byte 500
	size: 		.byte 0
	freeList 	.byte 0:100

initHead: .word 0
code:  .word 0

.text
main:
	la $a0 msg
	li $v0  4
	syscall
	
	li $v0, 5
	syscall
	sw $v0, size
	
	
	#print de prueba:
	la $a0 initHead
	li $v0  1
	syscall

	la $a0 msg1
	li $v0 4
	syscall

	lw $a0 size
	jal init
	
	#print de prueba:
	la $a0 initHead
	li $v0  4
	syscall
	
	jal end


init:
	lw $t0 heapsize
	lw $t1 size
	sgt $t2, $t1, $t0
	beq $t2, 1, code_init
	 
	#Se llama a init con los argumentos que hay en $a0
	li $v0, 9
	syscall
	
	sw $v0 initHead
	jr $ra

perror:
	sw $t0, code
	#seq $t2, $t0, -1
	beq $t0, -1, print_error_init

code_init:
	lw $t0, code
	addi $t0, $zero, -1
	j perror

print_error_init:
	la $a0 error_init
	li $v0 4
	syscall

	j end

test:
	la $a0 msg1
	addi $v0 $zero 4
	syscall
	jr $ra
	
end:
	li $v0 10
	syscall

malloc:
	
