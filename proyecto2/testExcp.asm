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

finProg1: .asciiz "El programa "
finProg2: .asciiz " ha finalizado.\n"
finalizado: .asciiz " (Finalizado) \n"
noFinalizado: .asciiz " (No Finalizado)\n"
programa: .asciiz "   Programa "
nroAdd: .asciiz "         Numero de add: "
shutdownMsg: .asciiz "La maquina ha sido apagada. Status de los programas: \n"
unknownBrk: .asciiz "Break desconocido: "
endl: .asciiz "\n"

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
	add $s1, $zero, $zero # s1 <- 0
	sll $s2, $s2, 2      # s2 *= 4
	add $s1, $s1, $s2    # s1 <- i+1
	srl $s2, $s2, 2      # s2 = s2 / 4
	
	lw $s3, NUM_PROGS    # $3 <- N			
	
	# for(int s2 = i+1; s2 < n; s2++)
	while_s2_lt_s3:
		bge $s2, $s3, end_while_s2_lt_s3
		
		add $s4, $zero, $s0
		add $s4, $s4, $s1
		lw $s4, 0($s4) # s4 <- finalizados[i]
		
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
		blt $s2, $s3, end_while_s2_gt_s3
		
		add $s4, $zero, $s0
		add $s4, $s4, $s1
		lw $s4, 0($s4) # s4 <- finalizados[i]
		
		# if(finalizados[i]==0)
		if_program_not_finished_prev:
			bnez $s4, end_if_program_not_finished_prev
			
			#Como este programa es el siguiente no finalizado, lo retornamos
			add $v0, $zero, $s2
			
			#Terminamos la ejecucion
			j returnPrev
		
		end_if_program_not_finished_prev:
		
	
		#i-=1
		subi $s2, $s2, 1
		subi $s1, $s1, 4
		j while_s2_gt_s3
	end_while_s2_gt_s3:
	
	# En caso de que aun no hayamos encontrado un programa finalizado, ahora empezamos 
	# desde atrás
	lw $s3, current # $s3 <- i
	
	lw $s2, NUM_PROGS       # s2 <- n-1
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
			j returnPrev
		
		end_if_program_not_finished_c:
	
		#i+=1
		subi $s2, $s2, 1
		subi $s1, $s1, 4
		j while_s2_gt_s3_b
	end_while_s2_gt_s3_b:
	
	#Si aun no encontramos uno que no haya finalizado, es que terminamos:
	li $v0, -1	
	
	returnPrev:
.end_macro

.macro storeProgram()
	#Guarda los registros del programa actual "current" en su correspondiente
	# espacio de backup.
	# k0: inicio del espacio del programa actual:
	# k1: programa actual:
	
	lw $k1, current # k1 <- i
	sll $k1, $k1, 2 # k1 *= 4
	
	lw $k0, backup	# k0 <- [0]
	add $k0, $k0, $k1
	lw $k0, 0($k0)  # k0 <- backup[i]	

	
	# Ahora procedemos a guardar los registros de este programa:
	sw $v0, 0($k0)
	sw $v1, 4($k0)
	sw $a0, 8($k0)	
	sw $a1, 12($k0)	
	sw $a2, 16($k0)	
	sw $a3, 20($k0)	
	sw $t0, 24($k0)
	sw $t1, 28($k0)
	sw $t2, 32($k0)	
	sw $t3, 36($k0)		
	sw $t4, 40($k0)		
	sw $t5, 44($k0)				
	sw $t6, 48($k0)
	sw $t7, 52($k0)	
	sw $s0, 56($k0)
	sw $s1, 60($k0)	
	sw $s2, 64($k0)
	sw $s3, 68($k0)
	sw $s4, 72($k0)	
	sw $s5, 76($k0)
	sw $s6, 80($k0)
	sw $s7, 84($k0)	
	sw $t8, 88($k0)	
	sw $t9, 92($k0)	
	sw $sp, 96($k0)
	sw $ra, 100($k0)
	mfc0 $k1, $14
	sw $k1, 104($k0) #Donde el programa quedo
																									
.end_macro

.macro loadProgram()
	 

	# Carga los registros del programa actual "current" en su correspondiente
	# espacio de backup.
	
	# k0: inicio del espacio del programa actual:
	# k1: programa actual:
	
	lw $k1, current # k1 <- i
	sll $k1, $k1, 2 # k1 *= 4
	
	lw $k0, backup	# k0 <- [0]
	add $k0, $k0, $k1 #k0 <- [i]
	lw $k0, 0($k0) 
	
	# Ahora procedemos a guardar los registros de este programa:
	lw $v0, 0($k0)
	lw $v1, 4($k0)
	lw $a0, 8($k0)	
	lw $a1, 12($k0)	
	lw $a2, 16($k0)	
	lw $a3, 20($k0)	
	lw $t0, 24($k0)
	lw $t1, 28($k0)
	lw $t2, 32($k0)	
	lw $t3, 36($k0)		
	lw $t4, 40($k0)		
	lw $t5, 44($k0)				
	lw $t6, 48($k0)
	lw $t7, 52($k0)	
	lw $s0, 56($k0)
	lw $s1, 60($k0)	
	lw $s2, 64($k0)
	lw $s3, 68($k0)
	lw $s4, 72($k0)	
	lw $s5, 76($k0)
	lw $s6, 80($k0)
	lw $s7, 84($k0)	
	lw $t8, 88($k0)	
	lw $t9, 92($k0)	
	lw $sp, 96($k0)
	lw $ra, 100($k0)
	lw $k1, 104($k0) #Donde el programa quedo
	mtc0 $k1, $14	
																								
.end_macro

.macro brk0x20()
	#Incrementa el contador adds[i] en uno cuando se 
	#detecta un break 0x20
	# k0: el índice del arreglo adds
	# k1: adds[i]
	
	lw $k0, adds # k0 <- [0]
	lw $k1, current # k1 <- i
	
	sll $k1, $k1, 2 # k1 *= 4
	
	add $k0, $k0, $k1 # k0 <- [i]
	
	lw $k1, 0($k0) # k1 <- adds[i]
	
	addi $k1, $k1, 1 # adds[i] += 1
	sw $k1, 0($k0)
	
	
.end_macro

.macro brk0x10()
	# Cuando se detecta un break 0x10 significa que el programa current
	# terminó, así que este se debe marcar como finalizado y cargar el siguiente
	# pograma. Si no se ha encontrado ningún programa para finalizar, entonces se 
	
	#Guardamos los registros de uso general:
	sw $v0, 0($sp)
	subi $sp, $sp, 4
	sw $a0, 0($sp)
	subi $sp, $sp, 4	
	
	
	#Finalizamos el programa current.
	finalizarPrograma()
	
	#Tenemos que actualizar el programa actual y buscar un programa que no haya 
	#sido finalizado.
	getNextProgram() #v0 <- i.next
	
	#Tenemos que verificar si todos los programas terminaron:
	bltz $v0, finishedAllProgs

	#Si no hemos terminado todos los programas, cargamos el siguiente
	sw $v0, current
	loadProgram()
		
	j return_brk0x10

	
	finishedAllProgs:
		li $v0, 10
		syscall 
				
	return_brk0x10:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
	addi $sp, $sp, 4
	lw $v0, 0($sp)	
.end_macro


.macro finalizarPrograma()
	#Esta funcion termina la ejecución del programa "current"
	#Tenemos que marcar este programa como finalizado e imprimir 
	# que ha finalizado
	# $t0: finalizados[i]
	# $t1: current (indice del programa actual)
	
	#Guardamos los registros de uso general:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
	sw $v0, 0($sp)
	subi $sp, $sp, 4
	
	
	#Guardamos en $t0 el indice del arreglo que se refiere a finalizados:
	lw $t0, finalizados #Direccion de inicio de finalizados [0]
	
	lw $t1, current     # t1 <- i
	sll $t1, $t1, 2
	
	add $t0, $t0, $t1 #$t0: [i]
	li $t1, 1         #$t1 <- 1

	#Marcar como finalizado:
		
	sw $t1, 0($t0) #finalizados[i] <- 1
	
	#Hay que imprimir que el programa ha finalizado:
	la $a0, finProg1  #print(finProg1)
	li $v0, 4
	syscall 
	
	lw $a0, current  #print(i)
	li $v0, 1          
	syscall
	
	la $a0, finProg2  #println(finProg2)
	li $v0, 4
	syscall 
	
	
		
	#Restauramos los registros que utilizamos:
	addi $sp, $sp, 4
	lw $v0, 0($sp)	
	addi $sp, $sp, 4
	lw $a0, 0($sp)	
	
		
.end_macro


.macro finalizarPrograma_q()
	#Esta funcion termina la ejecución del programa "current"
	#Tenemos que marcar este programa como finalizado y no imprime (quiet)
	# que ha finalizado
	# $t0: finalizados[i]
	# $t1: current (indice del programa actual)
	
	#Guardamos los registros de uso general:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
	sw $v0, 0($sp)
	subi $sp, $sp, 4
	
	
	#Guardamos en $t0 el indice del arreglo que se refiere a finalizados:
	lw $t0, finalizados #Direccion de inicio de finalizados [0]
	
	lw $t1, current     # t1 <- i
	sll $t1, $t1, 2
	
	add $t0, $t0, $t1 #$t0: [i]
	li $t1, 1         #$t1 <- 1

	#Marcar como finalizado:
		
	sw $t1, 0($t0) #finalizados[i] <- 1
	
	
		
	#Restauramos los registros que utilizamos:
	addi $sp, $sp, 4
	lw $v0, 0($sp)	
	addi $sp, $sp, 4
	lw $a0, 0($sp)		
		
.end_macro

.macro shutdown()
	# Finaliza silenciosamente todos los programas que no hayan sido finalizados, imprime
	# la cantidad de adds que consiguó cada uno. 

	# $t1: indice de iteración 
	# $t2: limite de iteracion
	
	#Imprimimos que la máquina ha sido apagada:
	la $a0, shutdownMsg
	li $v0, 4
	syscall
	
	
	# Ahora vamos a imprimir cuántos adds lleva cada programa
	# t0: indice del ciclo
	# t1: limite de iteracion
	li $t0, 0
	lw $t1, NUM_PROGS
	sw $zero, current
	
	while_SD_t0_lt_t1:
	bge $t0, $t1, end_while_SD_t0_lt_t1
		#imprimimos los adds del programa i
		
		#Guardamos los registros que usamos:
		sw $t0, 0($sp)
		subi $sp, $sp, 4
		sw $t1, 0($sp)
		subi $sp, $sp, 4
				
		printAdds()	
		
		#restauramos lo que usamos:
		addi $sp, $sp, 4
		lw $t1, 0($sp)
		addi $sp, $sp, 4
		lw $t0, 0($sp)
		
	
	#i+=1
	addi $t0, $t0, 1
	sw $t0, current
	j while_SD_t0_lt_t1
	end_while_SD_t0_lt_t1:
	
	#Salimos de la ejecución 
	li $v0, 10
	syscall
	
	
.end_macro

.macro printAdds()
	# Imprime el mensaje correspondiente a la cantidad de adds del programa
	# actual y si el programa ya finalizó.
	# $t0: finalizado[i]
	
	
	#Imprimimos "Programa"
	la $a0, programa
	li $v0, 4
	syscall
	
	#Imprimimos el programa actual:
	lw $a0, current
	addi $a0, $a0, 1
	li $v0, 1
	syscall
	subi $a0, $a0, 1
		
	#Ahora tenemos que ver si el programo ha finalizado o no.
	lw $t0, finalizados #t0: [0]
	sll $a0, $a0, 2
	add $t0, $t0, $a0   #t0: [i]
	lw $t0, 0($t0)      #t0: finalizados[i]
	
	if_t0_gt_0:
	beqz $t0, if_t0_eq_0
		#Imprimimos que este programa fue finalizado
		la $a0, finalizado
		li $v0, 4
		syscall
	
	
	j end_if_t0_eq_0
	if_t0_eq_0:

		#Imprimimos que este programa no fue finalizado
		la $a0, noFinalizado
		li $v0, 4
		syscall	
	
	end_if_t0_eq_0:
	
	#print("numero de adds: ")
	la $a0, nroAdd
	li $v0, 4
	syscall
	
	# Imprimimos numero de adds
	# $t0: inicio del arreglo de adds:
	# $a0: current
	lw $a0, current
	sll $a0, $a0, 2 
	lw $t0, adds
	add $t0, $t0, $a0 
	
	lw $a0, 0($t0) # $t0 <- adds[current]
	li $v0, 1  #print(adds[current])
	syscall
	
	la $a0, endl #imprimimos un salto de linea
	li $v0, 4
	syscall
	
	
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
	
	#Apagamos las interrupciones de teclado mientras manejamos la excepcion:
	lw $k1, 0xffff0000
	andi $k1, $k1, 1
	sw $k1, 0xffff0000
	
	move $k1 $at		# Save $at
	
	sw $v0 s1		# Not re-entrant and we can't trust $sp
	sw $a0 s2		# But we need to use these registers

	mfc0 $k0 $13		# Cause register
	srl $a0 $k0 2		# Extract ExcCode Field
	andi $a0 $a0 0x1f
	
	#Aquí podemos ver qué tipo de excepción fue. Lo que necesitamos es ver si 
	# a0==9. En caso de que lo sea, tenemos que cargar la instrucción que lo 
	# genero y verificar qué tipo de break era.
	#Guardamos t0:
	sw $s0, temp0
	#Guardamos el s0 el código que estamos buscando:
	li $s0, 9 # s0 <- 9
	if_Excp_is_brk:
		bne $s0, $a0,end_if_Excp_is_brk
		#Guardamos los registros que vamos a utilizar:
		sw $s1, temp1
		#Como a0==9, entonces la excepcion vino de un break, pero falta ver qué break fue
		mfc0 $s1, $14 # $s1 <- direccion de la instruccion break 
		
		#Extraemos el código del break:
		getBreakCode($s1) # v0 <- código del break
		
		#Ahora tenemos que identificar qué tipo de break es:
		if_break0x20:
			li $s0, 0x20
			bne $s0, $v0, if_break0x10
			#Llamamos al manejador de esta excepcion
			brk0x20()
		
			#restauramos los registros que usamos:
			lw $s1, temp1
			lw $s0, temp0
			#Configuramos la direccion de salto:
			mfc0 $k0 $14		# Bump EPC register
			addiu $k0 $k0 4		# Skip faulting instruction
						# (Need to handle delayed branch case here)
			mtc0 $k0 $14
			
			j end_break_if
		if_break0x10:
			li $s0, 0x10
			bne $s0, $v0, else_if_break
		
			brk0x10()
		
			#restauramos los registros que usamos:
			lw $s1, temp1
			lw $s0, temp0
			
			j end_break_if
		else_if_break:
			add $s0, $zero, $v0 # s0 <- código break obtenido
			la $a0, unknownBrk
			li $v0, 4
			syscall # print("Break desconocido: ")
			
			add $a0, $zero, $s0 #a0 <- codigo break
			li $v0, 1
			syscall #print(codigo encontrado)
			
			la $a0, endl
			li $v0, 4
			syscall #Imprime un salto de línea
		
		end_break_if:
		
		#Reactivamos las excepciones de teclado:
		lw $s0, 0xffff0000
		ori $s0, $s0, 2
		sw $s0, 0xffff0000
		
		#restauramos los registros que usamos:
		lw $s1, temp1
		lw $s0, temp0
		
				
		eret
	end_if_Excp_is_brk:
	
	# Ahora tenemos que ver si la excepción fue de teclado. Para hacer eso tenemos 
	# que verificar si $a0==0
	
	if_IO_Interrupt:
		bne $zero, $a0, end_if_IO_Interrupt
		#Como es una excepción de teclado, tenemos que ver que tecla se pulso.
		# [s]: carga el siguiente programa disponible.
		# [p]: carga el programa previo disponible
		# [esc]: termina la ejecución del programa
		# [else]: ignora la interrupcion y continua.
		
		sw $s1, temp1 #save s1
		# s0: tecla presionada
		# s1: informacion temporal
		lw $s0, 0xffff0004

		if_s_key:
			li $s1, 0x00000073 # s1 <- s
			bne $s0, $s1, if_p_key
			
			#Guardamos el programa actual:
			storeProgram()
			
			#Calculamos el siguiente programa a ejecutar y lo cargamos:
			getNextProgram()
			sw $v0, current
			
			loadProgram()
			
			
			j end_if_key
		if_p_key:
			li $s1, 0x00000070 #s1 <- p
			bne $s0, $s1, if_esc_key
			
			#Guardamos el programa actual:
			storeProgram()
			
			#Calculamos el siguiente programa a ejecutar y lo cargamos:
			getPrevProgram()
			sw $v0, current
			
			loadProgram()
			
			j end_if_key
		if_esc_key:
			li $s1, 0x0000001b #s1 <- esc
			bne $s0, $s1, else_key
			
			#Si se presiona esc, terminamos la ejecución.
			shutdown()
			
			
			j end_if_key		
		else_key:
			#Ignoramos la interrupción
			nop
		
		end_if_key:
	
		lw $s1, temp1 #restore s1
		lw $s0, temp0
		
		#restauramos input
		lw $k0, 0xffff0000
		ori $k0, $k0, 2
		sw $k0, 0xffff0000
		
		#Volvemos a lo que estabamos:
		eret
	end_if_IO_Interrupt:

	#restauramos lo que usamos
	lw $s0, temp0

	
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
	#Reactivamos las excepciones de teclado:
	lw $k0, 0xffff0000
	ori $k0, $k0, 2
	sw $k0, 0xffff0000
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
	temp0: .word 0   #Para guardar cosas en el ktext
	temp1: .word 0   #Para guardar cosas en el ktext
	temp2: .word 0   #Para guardar cosas en el ktext
		
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
	#Activamos las interrupciones de teclado:
	li $a0, 2 # a0 <- ..010
	sw $a0, 0xffff0000
	
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
	li $a0, 108 # a0 <- 27*4
	
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
	
	# Ahora tenemos que intrumentar los programas dados:
	
	# t0: iterador del arreglo
	# t1: indice de iteracion
	# t2: limite de iteracion
	# a0: direccion de inicio del siguiente programa
	
	la $t0, PROGS
	li $t1, 0
	lw $t2, NUM_PROGS 		

	
	# while(t1<t2)
	while_t1_lt_t2b:
	bge $t1,$t2, end_while_t1_lt_t2b
		# a0 = PROGS[i]
		lw $a0, 0($t0)

		#guardamos:
		sw $t0, 0($sp)
		subi $sp, $sp, 4
		sw $t1, 0($sp)
		subi $sp, $sp, 4
		sw $t2, 0($sp)
		subi $sp, $sp, 4
				
		jal instrumentar #Instrumentamos PROGS[i]

		#restauramos:
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
	
	#Ahora tenemos que conservar un estado inicial para que los programas puedan iniciar:
	# Vamos a iterar por el arreglo de backup y vamos a definir un estado inicial para 
	# cada programa:
	
	# $t0: iterador del ciclo
	# $t1: indice del ciclo 
	# $t2: limite de la iteracion.
	# $t3: indice del programa a almacenar.
	# $t4: [i] (progs)
	#
	lw $t0, backup   # $t0 <- backup
	li $t1, 0	 # $t1 <- 0
	lw $t2, NUM_PROGS# $t2 <- n
	li $t3, 0	 # $t3 <- backup[i]
	la $t4, PROGS
	
	# while(t1<t2)
	while_t1_lt_t2c:
	bge $t1,$t2, end_while_t1_lt_t2c

		#para almacenar el programa, vamos a tener que cambiar el current:		
		sw $t1, current
		
		storeProgram()
		
		#Como la dirección de retorno no es correcta, hay que actualizarla:
		lw $t3, 0($t0) # $t3 <- backup
		
		
		lw $t5, 0($t4) #t5 <- direccion de inicio del programa i
	
		sw $t5, 104($t3) #Guardamos la dirección de inicio del programa, donde 
				 #debe iniciar al ser llamado
	
		# i += 1
		addi $t0, $t0, 4
		addi $t1, $t1, 1
		addi $t4, $t4, 4	
	j while_t1_lt_t2c
	end_while_t1_lt_t2c:
	
	sw $zero, current
	
	# FIN DE INICIALIZACION

	
	lw $t1, PROGS 
	jr $t1
	
fin:
	li $v0 10
	syscall			# syscall 10 (exit)

.include "myprogs.s"
.include "instrumentador.asm"
