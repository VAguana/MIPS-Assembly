# SPIM S20 MIPS simulator.
# The default exception handler for spim.
#
# Copyright (C) 1990-2004 James Larus, larus@cs.wisc.edu.
# ALL RIGHTS RESERVED.
#
# SPIM is distributed under the following conditions:
#
# You may make copies of SPIM for your own use and modify those copies.
#
# All copies of SPIM must retain my name and copyright notice.
#
# You may not sell SPIM or distributed SPIM in conjunction with a commerical
# product or service without the expressed written consent of James Larus.
#
# THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE.
#

# $Header: $


# Define the exception handling code.  This must go first!

	.kdata
__m1_:	.asciiz "  Exception "
__m2_:	.asciiz " occurred and ignored\n"
__e0_:	.asciiz "  [Interrupt] "
__e1_:	.asciiz	"  [TLB]"
__e2_:	.asciiz	"  [TLB]"
__e3_:	.asciiz	"  [TLB]"
__e4_:	.asciiz	"  [Address error in inst/data fetch] "
__e5_:	.asciiz	"  [Address error in store] "
__e6_:	.asciiz	"  [Bad instruction address] "
__e7_:	.asciiz	"  [Bad data address] "
__e8_:	.asciiz	"  [Error in syscall] "
__e9_:	.asciiz	"  [Breakpoint] "
__e10_:	.asciiz	"  [Reserved instruction] "
__e11_:	.asciiz	""
__e12_:	.asciiz	"  [Arithmetic overflow] "
__e13_:	.asciiz	"  [Trap] "
__e14_:	.asciiz	""
__e15_:	.asciiz	"  [Floating point] "
__e16_:	.asciiz	""
__e17_:	.asciiz	""
__e18_:	.asciiz	"  [Coproc 2]"
__e19_:	.asciiz	""
__e20_:	.asciiz	""
__e21_:	.asciiz	""
__e22_:	.asciiz	"  [MDMX]"
__e23_:	.asciiz	"  [Watch]"
__e24_:	.asciiz	"  [Machine check]"
__e25_:	.asciiz	""
__e26_:	.asciiz	""
__e27_:	.asciiz	""
__e28_:	.asciiz	""
__e29_:	.asciiz	""
__e30_:	.asciiz	"  [Cache]"
__e31_:	.asciiz	""
__excp:	.word __e0_, __e1_, __e2_, __e3_, __e4_, __e5_, __e6_, __e7_, __e8_, __e9_
	.word __e10_, __e11_, __e12_, __e13_, __e14_, __e15_, __e16_, __e17_, __e18_,
	.word __e19_, __e20_, __e21_, __e22_, __e23_, __e24_, __e25_, __e26_, __e27_,
	.word __e28_, __e29_, __e30_, __e31_
s1:	.word 0
s2:	.word 0

### ZONA DE FUNCIONES ###

.macro getBreakCode($brk)
	# Si $brk es la direccion donde se encuentra un break, 
	# esta funcion retorna el código con el que fue llamada 
	# esa instruccion break.
	
	#Movemos la direccion a v0
	add $v0, $zero, $brk
	
	#Cargamos la instruccion en v0
	lw $v0, 0($v0)
	
	#Desplazamos los bits de la instruccion
	srl $v0, $v0, 6

.end_macro

.macro getNextProgram()
	#Returna el numero del siguiente programa no finalizado.
	#Si todos los programas han sido finalizados, retorna -1.
	# s0: inicio del arreglo "finalizados"
	# s1: iterador del ciclo
	# s2: indice del ciclo
	# s3: limite de iteracion
	# s4:  finalizados[i]
	
	lw $s2, current # s2 <- i+1
	addi $s2, $s2, 1
	
	lw $s0, finalizados
	add $s1, $zero, $zero # s1 <- [0]
	sll $s2, $s2, 2      # s2 *= 4
	add $s1, $s1, $s2    # s1 <- [i+1]
	srl $s2, $s2, 2      # s2 = s2 / 4
	
	lw $s3, NUM_PROGS    # $3 <- N			
	
	# for(int s2 = i+1; s2 < n; s2++)
	while_s2_lt_s3:
		bge $s2, $s3, end_while_s2_lt_s3
		
		lw $s4, 0($s1) # s4 <- finalizados[i]
		
		# if(finalizados[i]==0)
		if_program_not_finished:
			bnez $s4, end_if_program_not_finished
			
			#Como este programa es el siguiente no finalizado, lo retornamos
			add $v0, $zero, $s2
			
			#Terminamos la ejecucion
			j return
		
		end_if_program_not_finished:
		
	
		#i+=1
		addi $s2, $s2, 1
		addi $s1, $s1, 4
		j while_s2_lt_s3
	end_while_s2_lt_s3:
	
	# En caso de que aun no hayamos encontrado un programa finalizado, ahora empezamos 
	# desde atrás
	lw $s3, current # $s3 <- i
	
	li $s2, 0       # s2 <- 0
	add $s1, $zero, $s0 # s1 <- [0]
	
	
	# for(int s2 = 0, s2 <= i, s2++):
	while_s2_lt_s3_b:
		bgt $s2, $s3, end_while_s2_lt_s3_b	
	
		lw $s4, 0($s1) # s4 <- finalizados[i]
		
		# if(finalizados[i]==0)
		if_program_not_finished_b:
			bnez $s4, end_if_program_not_finished_b
			
			#Como este programa es el siguiente no finalizado, lo retornamos
			add $v0, $zero, $s2
			
			#Terminamos la ejecucion
			j return
		
		end_if_program_not_finished_b:
	
		#i+=1
		addi $s2, $s2, 1
		addi $s1, $s1, 4
		j while_s2_lt_s3_b
	end_while_s2_lt_s3_b:
	
	#Si aun no encontramos uno que no haya finalizado, es que terminamos:
	li $v0, -1	
	
	return:
.end_macro


.macro getPrevProgram()
	#Returna el numero del siguiente programa no finalizado.
	#Si todos los programas han sido finalizados, retorna -1.
	# s0: inicio del arreglo "finalizados"
	# s1: iterador del ciclo
	# s2: indice del ciclo
	# s3: limite de iteracion
	# s4:  finalizados[i]
	
	lw $s2, current # s2 <- i-1
	subi $s2, $s2, 1
	
	lw $s0, finalizados
	add $s1, $zero, $zero # s1 <- [0]
	sll $s2, $s2, 2      # s2 *= 4
	add $s1, $s1, $s2    # s1 <- [i-1]
	srl $s2, $s2, 2      # s2 = s2 / 4
	
	li $s3, 0    # $3 <- 0			
	
	# for(int s2 = i-1; s2 >= 0; s2--)
	while_s2_gt_s3:
		ble $s2, $s3, end_while_s2_gt_s3
		
		lw $s4, 0($s1) # s4 <- finalizados[i]
		
		# if(finalizados[i]==0)
		if_program_not_finished:
			bnez $s4, end_if_program_not_finished
			
			#Como este programa es el siguiente no finalizado, lo retornamos
			add $v0, $zero, $s2
			
			#Terminamos la ejecucion
			j return
		
		end_if_program_not_finished:
		
	
		#i+=1
		subi $s2, $s2, 1
		subi $s1, $s1, 4
		j while_s2_gt_s3
	end_while_s2_gt_s3:
	
	# En caso de que aun no hayamos encontrado un programa finalizado, ahora empezamos 
	# desde atrás
	lw $s3, current # $s3 <- i
	
	li $s2, NUM_PROGS       # s2 <- n-1
	subi $s2, $s2, 1
	
	add $s1, $zero, $s0 # s1 <- [n-1]
	sll $s2, $s2, 2
	add $s1, $s1, $s2
	srl $s2, $s2, 2
	
	# for(int s2 = n-1, s2 >= i, s2--):
	while_s2_gt_s3_b:
		blt $s2, $s3, end_while_s2_gt_s3_b	
	
		lw $s4, 0($s1) # s4 <- finalizados[i]
		
		# if(finalizados[i]==0)
		if_program_not_finished_c:
			bnez $s4, end_if_program_not_finished_c
			
			#Como este programa es el siguiente no finalizado, lo retornamos
			add $v0, $zero, $s2
			
			#Terminamos la ejecucion
			j return
		
		end_if_program_not_finished_c:
	
		#i+=1
		subi $s2, $s2, 1
		subi $s1, $s1, 4
		j while_s2_gt_s3_b
	end_while_s2_gt_s3_b:
	
	#Si aun no encontramos uno que no haya finalizado, es que terminamos:
	li $v0, -1	
	
	return:
.end_macro


#########################

# This is the exception handler code that the processor runs when
# an exception occurs. It only prints some information about the
# exception, but can server as a model of how to write a handler.
#
# Because we are running in the kernel, we can use $k0/$k1 without
# saving their old values.

# This is the exception vector address for MIPS-1 (R2000):
#	.ktext 0x80000080
# This is the exception vector address for MIPS32:
	.ktext 0x80000180
# Select the appropriate one for the mode in which MIPS is compiled.

	move $k1 $at		# Save $at
	
	sw $v0 s1		# Not re-entrant and we can't trust $sp
	sw $a0 s2		# But we need to use these registers

	mfc0 $k0 $13		# Cause register
	srl $a0 $k0 2		# Extract ExcCode Field
	andi $a0 $a0 0x1f

	# Print information about exception.
	#
	li $v0 4		# syscall 4 (print_str)
	la $a0 __m1_
	syscall

	li $v0 1		# syscall 1 (print_int)
	srl $a0 $k0 2		# Extract ExcCode Field
	andi $a0 $a0 0x1f
	syscall

	li $v0 4		# syscall 4 (print_str)
	andi $a0 $k0 0x3c
	lw $a0 __excp($a0)
	nop
	syscall

	bne $k0 0x18 ok_pc	# Bad PC exception requires special checks
	nop

	mfc0 $a0 $14		# EPC
	andi $a0 $a0 0x3	# Is EPC word-aligned?
	beq $a0 0 ok_pc
	nop

	li $v0 10		# Exit on really bad PC
	syscall

ok_pc:
	li $v0 4		# syscall 4 (print_str)
	la $a0 __m2_
	syscall

	srl $a0 $k0 2		# Extract ExcCode Field
	andi $a0 $a0 0x1f
	bne $a0 0 ret		# 0 means exception was an interrupt
	nop

# Interrupt-specific code goes here!
# Don't skip instruction at EPC since it has not executed.


ret:
# Return from (non-interrupt) exception. Skip offending instruction
# at EPC to avoid infinite loop.
#
	mfc0 $k0 $14		# Bump EPC register
	addiu $k0 $k0 4		# Skip faulting instruction
				# (Need to handle delayed branch case here)
	mtc0 $k0 $14


# Restore registers and reset processor state
#
	lw $v0 s1		# Restore other registers
	lw $a0 s2

	move $at $k1		# Restore $at

	mtc0 $0 $13		# Clear Cause register

	mfc0 $k0 $12		# Set Status register
	ori  $k0 0x1		# Interrupts enabled
	mtc0 $k0 $12

# Return from exception on MIPS32:
	eret

# Return sequence for MIPS-I (R2000):
#	rfe			# Return from exception handler
				# Should be in jr's delay slot
#	jr $k0
#	 nop



# Standard startup code.  Invoke the routine "main" with arguments:
#	main(argc, argv, envp)
#
	.text
	.globl __start
#	.globl main
__start:
	lw $a0 0($sp)		# argc
	addiu $a1 $sp 4		# argv
	addiu $a2 $a1 4		# envp
	sll $v0 $a0 2
	addu $a2 $a2 $v0
	jal main
	nop

	li $v0 10
	syscall			# syscall 10 (exit)

	.globl __eoth
__eoth:


	################################################################
	##
	## El siguiente bloque debe ser usado para la inicialización
	## de las estructuras de datos que Ud. considere necesarias
	## 
	## Las etiquetas QUANTUM, PROGS, NUM_PROGS no deben bajo 
	## ABSOLUTAMENTE NINGUNA RAZON ser definidas en este archivo
	##
	################################################################
	
	.data
	
	finalizados: .word 0 #Aquí llevaremos la cuenta de qué programas ya finalizaron su ejecución
	adds: .word 0 # Aquí llevamos la cuenta de cuantos adds lleva cada programa
	backup: .word 0 # Aqui esta la direccion del arreglo que contiene las direcciones de los 
			# arreglos que contienen el backup de los registros de uso general
			 
	current: .word 0 # Es el indice del programa actualmente en ejecucion. (i)

	################################################################
	##
	## El siguiente bloque debe ser usado para la inicialización
	## del planificador que Ud. considere necesarias, 
        ## instrumentación de los programas
        ## activación de interrupciones
	## inicialización de las estructuras
	## el mecanismo que comience la ejecución del primer programa
	################################################################

	.text
	
	.globl main
main:
	#Inicializamos:
	#Cargamos en a0 la cantidad de programas:
	lw $a0, NUM_PROGS
	# a0 *= 4:
	sll $a0, $a0, 2
	#Creamos el arreglo de finalizados:
	li $v0, 9
	syscall
	#finalizados = new int[n]
	sw $v0, finalizados
	
	#Creamos el arreglo de adds:
	li $v0, 9
	syscall
	#adds = new int[n]
	sw $v0, adds	
	  
	#Creamos el arreglo de backup:
	li $v0, 9
	syscall
	#backup = new int[n]
	sw $v0, backup
	
	#Vamos a llenar el arreglo de backup
	#Movemos la direccion de backup a un registro:
	# t0: iterador del arreglo
	# t1: indice de iteracion
	# t2: limite de iteracion
	# a0: espacio necesario para cada arreglo de registros
	
	lw $t0, backup
	li $t1, 0
	lw $t2, NUM_PROGS 		
	li $a0, 84 # a0 <- 21*4
	
	# while(t1<t2)
	while_t1_lt_t2:
	bge $t1,$t2, end_while_t1_lt_t2
		#Creamos el arreglo de backUp del programa i 
		li $v0, 9
		syscall
		
		#backup[i] <- new int[32]
		sw $v0, 0($t0)
	
		# i += 1
		addi $t0, $t0, 4
		addi $t1, $t1, 1	
	j while_t1_lt_t2
	end_while_t1_lt_t2:
	
	# FIN DE INICIALIZACION
	
	

	lw $t1, PROGS 
	#jr $t1
	
fin:
	li $v0 10
	syscall			# syscall 10 (exit)

.include "myprogs.s"