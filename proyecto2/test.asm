#ARCHIVO DE PRUEBA



.text
	la $t0, PROGS
	li $t1, 0
	lw $t2, NUM_PROGS 		

	
	# while(t1<t2)
	while_t1_lt_t2b:
	bge $t1,$t2, end_while_t1_lt_t2b
		# a0 = PROGS[i]
		lw $a0, 0($t0)
		
		sw $t0, 0($sp)
		subi $sp, $sp, 4
		sw $t1, 0($sp)
		subi $sp, $sp, 4
		sw $t2, 0($sp)
		subi $sp, $sp, 4				
		
		jal instrumentar #Instrumentamos PROGS[i]
		
		addi $sp, $sp, 4
		lw $t2, 0($sp)
		addi $sp, $sp, 4
		lw $t1, 0($sp)
		addi $sp, $sp, 4
		lw $t0, 0($sp)				
	
		# i += 1
		addi $t0, $t0, 4
		addi $t1, $t1, 1	
	j while_t1_lt_t2b
	end_while_t1_lt_t2b:
	li $v0, 10
	syscall

.include "instrumentador.asm"
.include "myprogs.s"
