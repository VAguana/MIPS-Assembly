#Vamos a definir una linked list:

.data
	space: .asciiz " "	
.macro create($size)

	#Estructura de la lista:
	#|4bytes: inicio | 4bytes: fin | 4bytes: numero de elementos |
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
	
	#Guardamos registros: $v0
	sw $v0, ($sp)
	addi $sp, $sp, -4
	
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
	#restauramos registros 
	addi $sp, $sp, 4
	lw $v0, 0($sp)
.end_macro	

.macro delete($lista, $pos)
	#lista: apuntador a la lista cuyo elemento queremos eliminar.
	#pos: la posicion del elemento en la lista (primero, segundo, tercero...)
	
	#Cargamos en t0 la direccion de la lista:
	add $t0, $zero, $lista #t0: posicion de la lista
	
	#cargamos en t1 la posicion del elemento:
	add $t1, $zero, $pos #t1: posicion EN la lista
	
	#Cargamos en t2 el numero de elementos de la lista:
	lw t2, 8($t0)
	
	#Verificamos si hay algo que eliminar:
	# ¿pos > nelements? No hay nada que eliminar, termina:
	bgt $t1, $t2, _endDelete
	

	
	#Como podemos eliminar, cargamos en t3 el primer elemento de la lista y vamos buscando:
	jal first($t0)
	
	add $t3, $zero, $v0 #t3: apuntador al primer elemento
	
	#Ahora usamos t4 como contador:
	addi $t4, $zero, 1 #t4: contador
	
	#iteramos para encontrar el elemento correcto hasta su posicion anterior
	_whileT4NotPrev:
		next($t3)
		addi $t3, $v0, 0 #t3 = t3.siguiente
		addi $t4, $zero, 1 #t4 += 1
		
		blt $t4, $t1, _whileT4NotPrev
	#Encontramos el previo del elemento, ahora guardamos su siguiente.
	next($t3)
	add $t5, $v0, $zero # t5 = elemento a eliminar
	#Buscamos el siguiente del elemento a eliminar 
	next($t5)
	add $t6, $zero, $v0 # t6 = elementoAEliminar.next
	
	#Configuramos el siguiente del previo correctamente:
	sw $t6, 4($t3) #elemento.prev.next = elemento.next
	
	#Cargamos en v0 la dirección del elemento que era direccionado por el nodo eliminado
	lw $v0, 0($t3)
	
	#NOT YET IMPLEMENTED: liberamos el espacio del nodo:
	#free($t3)
	
	
	

	
	    
	

	_endDelete:
.end_macro

.macro malloc($bytes)
	add $a0, $zero, $bytes
	addi $v0, $zero, 9
	syscall
.end_macro

.macro fun_print($nodeDir)
	
	#Guardamos los registros que vamos a utilizar: a0, v0
	sw $v0, 0($sp)
	sw $a0, -4($sp)
	addi $sp, $sp, -8
	
	# nodedir: es la dirección del nodo que vamos a imprimir
	
	add $t8, $zero, $nodeDir # t8: nodeDir
	lw $a0, 0($t8) # a0 <- apuntador al elemento
	lw $a0, 0($a0)
	addi $v0, $zero, 1
	syscall
	
	#Recuperamos lo que guardamos:
	lw $a0, 4($sp)
	lw $v0, 8($sp)
	addi $sp, $sp, 8
	
	
.end_macro


.macro print($lista,$function)
	#Guardamos los registros que usamos:
	sw $a0, 0($sp)
	addi $sp, $sp, -4
	#Guardamos la dirección de lista en t0
	add $t0, $zero, $lista
	#En t1 vamos a llevar el siguiente elemento a imprimir, empezamos con el primero:
	add $a0, $zero, $t0
	jal first
	add $t1, $zero, $v0 #t1: primer elemento
	
	_printWhileT1NotZero:
		beqz $t1, _endPrint
		$function($t1)
		#Incrementamos t1:
		add $a0, $zero, $t1
		jal next
		add $t1, $zero, $v0
		
		la $a0, space
		addi $v0, $zero, 4
		syscall
		
		bnez $t1, _printWhileT1NotZero
		
	#recuperamos lo guardado
	addi $sp, $sp, 4
	lw $a0, ($sp)
	_endPrint:		
	#return: dirección del nodo siguiente al nodo dado. 
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
	malloc(4)
	add $s1, $zero, $v0
	addi $s2, $zero, 100
	sw $s2, 0($v0)
	insert($s0,$s1)
	
	print($s0, fun_print)
	#fun_print()
	
	j end



first:


	#a0: direccion de la lista cuyo primero queremos obtener
	lw $v0, 0($a0)
	
	jr $ra
	#return: la dirección del primer elemento

next:
	#a0: elemento cuyo siguiente queremos obtener
	#Guardamos los registros:

	
	
	lw $v0, 4($a0)
	
	
	#volvemos
	jr $ra

end:
	li $v0 10
	syscall

#push:
     #Template para empilar registros. NO ES UNA FUNCIÓN.
#     sw registro, -0($sp)
#     addi $sp,	$sp, -4
