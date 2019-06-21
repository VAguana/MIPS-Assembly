.ktext 0x80000180
	

	addi $s0, $s0, 1



	eret

.text

	#inicilizamos el control del receptor:
	li $t0, 2
	sw $t0, 0xffff0000


	wtf:
	
	addi $s1, $s1, 1
	
	j wtf
	
	li $v0 10
	syscall