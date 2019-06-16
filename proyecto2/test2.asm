


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


.macro getOffset($pos)
	# Dado un beq alojado en la posicion $pos, devuelve el offset
	# al que esta destinado a saltar dicho beq
	
	#Guardamos la posicion en $t0:
	add $t0, $zero, $pos
	
	#Cargamos la instruccion en $v0
	lw $v0, 0($t0)
	
	#Eliminamos todos los bits que no sean los primeros 16:
	andi $v0, $v0, 65535
	
	#pasamos  el valor obtenido a longitud de 32 bits:
	shortToNormal($v0)
.end_macro



.macro setOffset($pos, $val)
	#Cambia el offset de salto del beq almacenado en la posicion
	# $pos por el especificado en el registro $val
	# guardamos el $s0:
	sw $s0, 0($sp)
	subi $sp, $sp, 4
	#Guardamos la posicion en $t0:
	add $t0, $zero, $pos
	
	#Guardamoas el offset en s0:
	add $s0,$zero, $val
	
	#Cargamos la instruccion en $v0
	lw $v0, 0($t0)
	
	#Eliminamos los primeros 16 bits:
	andi $v0, $v0, -65536
	
	
	#Eliminamos los últimos 16 bits (lo convertimos en short)
	andi $s0, $s0, 65535
	
	#Añadimos el offset a la instruccion:
	or $v0, $v0, $s0
	
	#Restauramos la instruccion a su posicion correspondiente:
	sw $v0, 0($t0)
	
	
	#restauramos los registros usados:
	addi $sp, $sp, 4
	lw $s0, 0($sp)
.end_macro

.macro normalToShort($val)
	#Recibe un numero en el registro $val y lo convierte 
	#de formato de 32 bits a formato de 16 bits:
	sw $s0, 0($sp)
	subi $sp, $sp, 4
	sw $s1, 0($sp)
	subi $sp, $sp, 4

	
	
	#Guardamos el numero en un registro:
	add $s0, $zero, $val
	
	#Vamos a eliminar todos los bits salvo los primeros 16
	andi $s0, $s0, 65535
	
	#retornamos
	add $v0, $zero, $s0

	addi $sp, $sp, 4
	lw $s1, 0($sp)
	addi $sp, $sp, 4
	lw $s0, 0($sp)
	
.end_macro

.macro shortToNormal($val)
	#recibe un numero en complemento 2 de 16 bits en el 
	#registro $val
	# y lo pasa a complemento 2 de 32 bits
	# Guardamos los t, puesto que esta funcion se utiliza 
	# en otras funciones
	sw $t0, 0($sp)
	subi $sp, $sp, 4 
	sw $t1, 0($sp)
	subi $sp, $sp, 4


	
	#el número en un registro:
	add $t0, $zero, $val
	
	#Revisamos si es negativo, si no lo es, el ńúmero permanece igual
	andi $t1, $t0, 32768 # Quitamos todos los bits menos el 16
	beqz $t1, return #como es positivo, se queda igual
	
	#como es negativo, primero hay que convertirlo:
	subi $t0, $t0, 1
	ori $t0, $t0, 4294901760 #Ponemos todos los bits previos al bit 16 encendidos
	not $t0, $t0  #Anulamos el not previo. En este punto, tenemos el valor absoluto 
		      #del numero que tenemos
	#convertimos a complemento 2
	not $t0, $t0
	addi $t0, $t0, 1
	
	return:
	add $v0, $zero, $t0
	
	#Restauramos los registros:
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	lw $t0, 0($sp)

.end_macro


.text
	#Vamos a cargar en los s los valores de NUM_PROGS, QUANTUM, y PROGS
	# s0: PROGS 
	# s1: NUM_PROGS
	# s2: QUANTUM
	
	lw $a0, PROGS
	

	getOffset($a0)
	addi $a1, $zero, 4
	#setOffset($a0, $a1)
	#getOffset($a0)

	
	
	
	li $v0, 10
	syscall	
	 
	





.include "myprogstest.asm"
