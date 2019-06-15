
.macro isAdd($pos)
	# Determina si una instrucción en la posicion "pos" es una instruccion
	# de add
	# t0: posicion de la instruccion:
	
	#Guardamos la pusicion en t0:
	
	add $t0, $zero, $pos
	
	#Cargamos en v0 la instruccion en cuestion:
	lw $v0, 0($t0)
	
	#Eliminamos todos los bits distintos a los primeros 6:
	andi $v0, $v0, 63
	
	# v0 <- v0 == 32 (32 es el codigo de op del add)
	seq $v0, $v0, 32
.end_macro

.macro isBeq($pos)
	# Determina si una instrucción en la posicion "pos" es un beq
	# t0: posicion de la instruccion
	
	#Guardamos la posicion en t0:
	add $t0, $zero, $pos
	
	#Cargamos en $v0 la instruccion en cuestoon:
	lw $v0, 0($t0)
	
	#Eliminamos todos los bits distintos de los últimos 6:
	andi $v0, $v0, 4227858432
	
	#Vemos si en esos bits hay un 4:
	
	seq $v0, $v0, 268435456

.end_macro

.macro isNop($pos)
	#Determina si una instruccion alamacenada en la posicion "pos"
	# es una nop
	# t0: posicion donde esta la instruccion
	
	#cargamos la posicion en t0:
	add $t0, $zero, $pos
	
	# Cargamos la instruccion en v0:
	lw $v0, 0($t0)
	
	# Vemos si esta instruccion es igual a 0:
	seq $v0, $v0, 0
	
.end_macro

.macro isSyscall10($pos)
	# Determina si la instruccion almacenada en la posicion 
	# es una instrucción li $v0, 10
	# t0: direccion de la instruccion:
	add $t0, $zero, $pos
	
	#Cargamos la instruccion en v0:
	lw $v0, 0($t0)
	
	#Vemos si la instruccion es igual a li,$v0, 10 (0x2402000A)
	seq $v0, $v0, 0x2402000A #v0 <- v0 == 0x2402000A
.end_macro

instrumentar:
	#Guardamos los registros que vamos a utilizar:
	# a0:
	sw $a0, 0($sp)
	subi $sp, $sp, 4

	# Esta funcion instrumenta un programa cuya direccion 
	# de inicio esta en a0. Se asume que en cada programa
	# a instrumentar, al final, se encuentra la misma can
	# tidad de de NOP que de instrucciones add, para tener
	# suficiente espacio para las instrucciones break.
	
	# t1: indice para iterar sobre el programa 
	# t2: contador de instrucciones, debe finalizar con el número 
	#     de instrucciones del programa
	# t3: arreglo con desplazamientos
	
	# Primero vamos a necesitar saber que tan largo es el 
	# programa:
	
	# inicializamos t2:
	addi $t2,$zero, 0 #t2 <- 0
	
	# Inicializamos t1:
	add $t1, $zero, $a0 #t1 <- direccion de inicio del programa
	
	# Inicializamos v0:
	li $v0, 0
	
	#vamos a contar cuantas instrucciones tiene 
	While_t1_not_syscall10:
		beq $v0, 1, end_while_t1NS10 # v0 == syscall 10? exit.
		
		addi $t2, $t2, 1 # Incrementamos el contador de instrucciones
		
		isSyscall10($t1) # Verificamos si la instruccion actual es un syscall 10
		
		addi $t1, $t1, 4 # Nos movemos 1 instruccion en el programa
		
	
		j While_t1_not_syscall10
	end_while_t1NS10:
	#Ahora que t1 se encuentra en la posicion de un syscall, vamos a cambiar el syscall 
	#por un break 0x10
	
	#Guardamos temporalmente en t3 el valor del código de la operacion:
	li $t3 0x0000040d #t3 <- break 0x10
	
	# Guardamos el valor de este registro en el syscall del programa que estamos 
	# modificando:
	
	sw $t3, 0($t1)
	
	# /// ETAPA 2: CONTEO ///
	# A continuacion vamos a contar la cantidad de posiciones que cada instruccion
	# del programa se vera desplazada luego de añadir los break. Para esto creamos
	# un arreglo del tamaño de la cantidad de instrucciones del programa: 

	#Guardamos la posicion del inicio del programa en t1 de nuevo:
	add $t1, $a0, $zero

	#Sumamos 1 a la cantidad de operaciones encontradas para añadir también el break:
	addi $t2, $t2, 1
	
	#Creamos un arreglo para guardar el desplazamiento:
	#	Pedimos 4*nInstrucciones bytes:
	sll $a0, $t2, 2 # a0 <- 4*t2
	li $v0, 9
	syscall
	
	#Guardamos el apuntador al arreglo obtenido en t3:
	add $t3, $zero, $v0
	
	# Usaremos t4 y t5 para iterar sobre el programa y el arreglo de conteo respectivamente:
	# t6 será el límite de la iteración, y t7 para mover entre memoria y registros.
	# Inicializamos:
	add $t4, $zero, $t1 #t4 <- inicio del programa
	add $t5, $zero, $t3 #t5 <- inicio del arreglo de conteo
	li $t6, 1 # t6 <- 1 (i:=1)
	li $t7, 0 # t7 <- 0
	
	#Vemos si la primera instruccion es un add:
	if_Program0_isAdd:
		isAdd($t4) # v0 <- program[0] is add
		beqz $v0, end_ifProgram0_isAdd
		
		li $t7, 1
		sw $t7, 4($t5) # conteo[1] := 1	
	
	end_ifProgram0_isAdd:
	
	#Avanzamos una posicion en el programa y en el arreglo de conteo:
	addi $t4, $t4, 4
	addi $t5, $t5, 4
	#Ahora vamos a iterar sobre el programa:
	while_t6_lesst_t2:
		bge $t6, $t2,end_while_t6_lesst
		
		#t8: variable temporal para guardar el contenido de la posicion i 
		#    del conteo:
		
		# conteo[i] += conteo[i-1]
		lw $t7, -4($t5)
		lw $t8, ($t5)
		add $t7, $t7, $t8
		sw $t7, 0($t5)
		
		#if(Program[i]==add)
		if_Programi_equals_add:
			#v0 <- Prgram[i] es add
			isAdd($t4)
			beqz $v0, end_if_Programi_equals_add
			
			#conteo[i+1] = 1
			li $t7, 1
			sw $t7, 4($t5)
		end_if_Programi_equals_add:		
		
		#i += 1
		addi $t6, $t6, 1
		addi $t4, $t4, 4
		addi $t5, $t5, 4
				
		j while_t6_lesst_t2
	end_while_t6_lesst:
	
	
	# /// FASE 3: INSTRUMENTAR ///
	# Ahora vamos a reubicar las instrucciones existentes en sus 
	# correspondientes posiciones, e insertaremos los break 0x20
	# donde es oportuno.
	
	# $t4: indice del programa 
	# $t5: índice del arreglo de conteo
	# $t6: iterador del ciclo 
	# $t7: last (el último valor hayado en el arreglo de conteo)
	# $t8: Nueva posicion de la instruccion i
	# $t9: Informacion temporal
	
	#Inicializamos:
	subi $t4, $t4, 4 # t4 <- fin del programa
	subi $t5, $t5, 4 # t5 <- fin del arreglo de conteo
	subi $t6, $t6, 1 # t6 <- 0 (i:=nInstrucciones-1)
	lw $t7, 0($t5)      # t7 <- conteo[n-1]
	
	while_t6_bget_zero:
		bltz $t6,end_while_t6_bget_zero
		#Cargamos en t8 la posicion nueva que tedrá la instruccion i
		add $t8,$zero, $t4
		lw $t9, 0($t5) #$t9 <- conteo[i]
		sll $t9, $t9, 2 # Como en conteo esta la cantidad de instrucciones que hay que
				# desplazar, es necesario multiplicar por 4 para cambiarlo
				# a palabras.
		add $t8, $t8, $t9 # $t8 <- i + conteo[i]
		
		#Ahora guardamos en la posicion indicada por t8 la intruccion i:
		lw $t9, 0($t4) # $t9 <- programa[i]
		sw $t9, 0($t8) # programa[i+conteo[i]] <- programa[i]
		
		#Cargamos en $t9 el contador actual otra vez:
		lw $t9, 0($t5)
		#if last != conteo[i]
		if_current_not_eq_last:
			beq $t7, $t9, end_if_current_not_eq_last
			#Actualizamos el last:
			add $t7, $zero, $t9
			# programa[i + conteo[i] + 1] = programa[i]
			addi $t8, $t8, 4 # $t8 <- i + conteo[i] + 1
			li $t9,0x0000080d # $t9 <- break 0x20
			sw $t9, 0($t8)
		end_if_current_not_eq_last:
		
		#i -= 1
		subi $t6, $t6, 1
		subi $t4, $t4, 4
		subi $t5, $t5, 4		
		

		j while_t6_bget_zero
	end_while_t6_bget_zero:		
	
	# /// FASE 4 ///
	
	# Ahora tenemos que recorrer el programa buscando los beq para corregir sus offset
	# $t4: indice del programa
	# $t5: indice del arreglo de conteo
	# $t6: iterador del ciclo
	# $t7: desplazamiento actual (conteo[i])
	# $t8: índice del desplazamiento del anterior (i - programa[i].offset)
	# $t9: desplazamiento anterior 
	
	#inicializamos:
	add $t4, $zero, $t1 # $t4 <- Posicion inicial del programa
	add $t5, $zero, $t3 # $t3 <- Posicion inicial del arreglo de conteo
	li $t6, 0           # $t6 <- 0 (i = 0)
	
	#Ahora vamos a iterar sobre el programa:
	while_t6_lesst_t2b:
		bge $t6, $t2,end_while_t6_lesstb
		isBeq($t4)
		#if Program[i] is beq
		if_instrc_isBeq:
		beqz $v0, end_if_instrc_isBeq
			getOffset($t4) # $v0 <- program[i].offset
			lw $t7, 0($t5) #$t7 <- conteo[i]
			
			#Ahora en t8 vamos a poner la dirección a la que salta el beq
			add $t8, $t5, $zero
			sub $t8, $t8, $v0 # $t8 = i - program[i].offset

			#Cargamos en t9 conteo[i - program[i].offset]
			lw $t9, 0($t8)
			
			#Configuramos el nuevo valor de offset en $t9 
			sub $t9, $t7, $t9 # $t9 <- conteo[i] - conteo[i-program[i].offset]
			sll $t9, $t9, 2   # $t9 <- t9 *= 4
			
			add $v0, $v0, $t9
			
			setOffset($t4, $v0)
			
			
			
			
		
		end_if_instrc_isBeq:
		
		# i += 1
		addi $t6, $t6, 1
		addi $t4, $t4, 4
		addi $t5, $t5, 4
		
	
		j while_t6_lesst_t2b
	end_while_t6_lesstb:	
	
	
			
	#Restauramos los registros que vamos a utilizar
	addi $sp, $sp, 4	
	lw $a0, 0($sp)
	
	jr $ra

.data
	.globl instrumentar
	count: .word 0




