.data
	count: .word 0

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




	
.text
	li $v0, 10
	syscall

.include "myprogs.s"