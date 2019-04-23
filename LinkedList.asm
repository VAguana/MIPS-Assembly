#Vamos a definir una linked list:

.data
	#La lista "L" tiene como atributos head y tail.
 	L: .space 4
	L.head: .space 4 
	L.tail: .space 4
	L.nElements: .word 0

#	Forma de una lista: 
#	| 4b:head ptr | 4b: tail ptr | 4b: nElements |	
	head: .space 4
	tail: .space 4
.macro create($size)
	#size es el tamaño de los elementos que van a estar contenidos en la lista 
	#Primero tenemos que alojar el espacio total que vamos a necesitar para la lista:
	malloc(12)

	#Ahora tenemos que alojar las diferentes parte de la estructura de lista.
	
	#Damos valor  al número de elementos:
	sw $zero, 8($v0)
	
	#Asignamos 0 a los valores de la head y la tail
	sw $zero, ($v0)
	sw $zero, 4($v0)
	
.end_macro

.macro insert($lista_ptr,$dir)
	#lista_ptr: apuntador a la lista (realmente la head de la lista)
	#dir: dirección del elemento a añadir en la lista
	
	#|4bytes: direccion elemento | 4bytes: siguiente|
	malloc(8)
	# Guardamos nuestros datos:
	add $t0, $zero, $lista_ptr # t0: apuntador a la lista 
	add $t1, $zero, $dir       # t1: direccion del elemento a añadir
	lw $t3, 8($t0)		   # t3: numero de elementos en la lista
	
	#Ahora configuramos las posiciones correspondientes en las posiciones correspondientes
	sw $t1, 0($v0)
	
	#Configuramos el siguiente como null
	sw $zero, 4($v0)
	
	#¿numero de elementos == 0? No hay tail cuyo siguiente deba ser configurado:
	beqz $t3, _correctTail
	#Configuramos este elemento como el siguiente de la tail
	lw $t2, 4($t0)  #t2: apuntador a la tail actual
	sw $v0, 4($t2)  #Esto hace que el siguiente de la tail de la lista sea igual al nodo que acabamos de crear
	
	_correctTail:
	#Configuramos este elemento como tail:
	sw $v0, 4($t0)
	
	#Si el contador de elementos es == 0, configuramos este nuevo nodo como primero:
	lw  $t2, 8($t0)      # t2: cantidad de elementos en la lista
	bnez $t2, _endInsertSucc # ¿NumeroElementos!=0? No hace falta configurarlo como 0
	
	sw $v0, 0($t0)   # head <- nuevo elemento
	
	_endInsertSucc:
		addi $t2, $t2, 1
		sw $t2, 8($t0)
.end_macro	

.macro malloc($bytes)
	add $a0, $zero, $bytes
	addi $v0, $zero, 9
	syscall
.end_macro

.text

	#Creamos una lista
	create(8)
	add $s0, $zero, $v0 # s0: lista
	malloc(4) 	    # alojamos espacio para un numero	
	add $s1, $zero, $v0 # s1: numero nuevo que creamos
	addi $s2, $zero, 7  
	sw $s2, 0($v0)      # numero nuevo <- 7
	insert($s0,$s1)
	malloc(4)
add $s1, $zero, $v0 # s1: numero nuevo que creamos
	addi $s2, $zero, 7  
	sw $s2, 0($v0)      # numero nuevo <- 7
	insert($s0,$s1)	
	
	j end


NewList:
	#Contructor de lista. Crea nodos que contengan datos con el tamaño
	#indicado en a0, retorna un apuntador a la lista. Esta lista va a 
	#contener un apuntador a la head en los primeros 4 bytes y a uno la tail
	# en los siguientes 4. En los últimos 4 bytes está la cantidad de elementos.
	
	#Guardamos lo que vamos a usar: s0,s1,s2, ra
	sw $s0, -0($sp)
	addi $sp, $sp, -4
	
	sw $s1, -0($sp)
	addi $sp, $sp, -4
	
	sw $ra, -0($sp)
	addi $sp, $sp, -4
	
	
	#ahora guardamos el argumento (a0) en s0:
	move $s0, $a0
	
	#Creamos un nodo de la lista:
	addi $a0, $a0, 4
#	jal malloc
	
	#Guardamos este nodo en s1, será el head y la tail de la lista.
	move $s1, $v0
	#Configuramos el siguiente de este nodo como 0 (null)
	addi $v0, $v0, 4
	sw $zero, ($v0)
	
	#Alojamos el espacio para la lista, una lista necesita 16 bytes:
	addi $a0, $zero, 16
#	jal malloc
	
	#Configuramos el head y tail de la lista que creamos como el nuevo nodo:
	sw $s1, ($v0)
	sw $s1, 4($v0)		
	
	#Configuramos el número actual de elementos como 0:
	sw $zero, 8($v0)
	
	#Configuramos el tamaño del nodo como el tamaño dado y guardado en s0
	sw $s0, 12($v0)
	
	#Restauramos los registros utilizados:
	lw $ra 4($sp)
	lw $s1 8($sp)	
	lw $s0 12($sp)	
	addi $sp $sp 12
	#volvemos
	jr $ra

end:
	li $v0 10
	syscall

#push:
     #Template para empilar registros. NO ES UNA FUNCIÓN.
#     sw registro, -0($sp)
#     addi $sp,	$sp, -4
