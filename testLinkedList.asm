
	
.macro newNumber($number)
	add $t0, $zero, $number
	malloc(4)
	sw $t0, 0($v0)
.end_macro
	
.macro create()
	### DESCRIPCION ###
	# Instancia una lista y devuelve la posicion de memoria donde está la cabeza de esa lista

	### Estructura de la lista ###
	#|4bytes: inicio | 4bytes: fin | 4bytes: numero de elementos |
	
	### ATRIBUTOS ###
	# inicio: dirección donde se encuentra el primer nodo de la lista.
	
	# fin: dirección donde se encuentra el último nodo de la lista. Cuando fin == inicio == 0x0
	#      es porque no existen nodos en la lista.
	
	# numero de elementos: Cantidad de elementos actualmente insertados en la lista.
	
	### RETURN ###
	
	# La dirección donde se alojó la lista
	
	### Implementacion ###
	
	# Se alojan 12 bytes de espacio; 4 para el valor del atributo "inicio", 4 para el valor del atributo "fin"
	# y 4 para el número de elementos. "Inicio" y "fin" empiezan valiendo 0x0 originalmente, y el número 
	# de elementos empieza en 0.
	
	### --- ###
	
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
	### DESCRIPCION ###
	# Dada una lista, inserta el elemento cuya direccion es "dir" en la lista
	
	### ENTRADA ###
	
	#lista_ptr: apuntador a la lista (realmente la head de la lista)
	
	#dir: dirección del elemento a añadir en la lista
	
	### ESTRUCTURA DE UN NODO ###
	# |4bytes: direccion elemento | 4bytes: siguiente|
	
	### ATRIBUTOS DE UN NODO ###
	# direccion elemento: direccion en la memoria donde se encuentra el elemento 
	#		      correspondiente con este nodo.
	
	# siguiente: dirección del siguiente nodo en la lista. Si el valor de siguiente es 0x0, 
	#            entonces no tiene siguiente y por lo tanto este nodo es la tail (final) de la lista.
	
	### IMPLEMENTACIÓN ### 
	
	# Se instancia el nodo en cuestion utilizando un malloc(8) y luego asignando el contenido
	# de sus bytes como se indica en la estructura. Este nodo se asigna como siguiente del nodo "final".
	# Si es el primero en ser añadido entonces también se define como head,y en este caso tampoco hay tail
	# asi que se asigna directamente sin ser el siguiente de ningún otro nodo.
	
	### --- ###	


	# Guardamos nuestros datos:
	add $t0, $zero, $lista_ptr # t0: apuntador a la lista 
	add $t1, $zero, $dir       # t1: direccion del elemento a añadir
	lw $t3, 8($t0)		   # t3: numero de elementos en la lista
	
	#Creamos el espacio del nodo:
	malloc(8)	
	
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

.macro delete($lista, $pos)

	### ENTRADA ###
	# lista: apuntador a la lista cuyo elemento queremos eliminar.
	# pos: la posicion del elemento en la lista (primero, segundo, tercero...)
	
	### SALIDA ###
	# La direccion del elemento que fue eliminado de 
	
	### IMPELEMENTACION ###
	
	# Se implementa la eliminacion usual de las listas enlazadas.
	# Se consideran varios casos bordes: en el caso donde se pide una
	# posicion que excede el tamaño de la lista, el programa genera un error.
	# En el caso donde se elimina el único elemento de la lista, esta se vacía.
	# en el caso donde se elimina el primero o el último de la lista, estos 
	# atributos son actualizados en la head de la lista.
	
	### --- ###
	
	#Cargamos en t0 la direccion de la lista:
	add $t0, $zero, $lista #t0: posicion de la lista
	
	#cargamos en t1 la posicion del elemento:
	add $t1, $zero, $pos #t1: posicion EN la lista
	
	#Cargamos en t2 el numero de elementos de la lista:
	lw $t2, 8($t0) #t2: numero de elementos:
	
	#Verificamos si hay algo que eliminar:
	# ¿pos > nelements? No hay nada que eliminar, termina:
	bgt $t1, $t2, _endDelete
	
	#Como podemos eliminar, cargamos en t3 el primer elemento de la lista y vamos buscando:
	add $a0, $zero, $t0
	jal first
	
	add $t3, $zero, $v0 #t3: apuntador al primer elemento
	
	# Ahora verificamos si el elemento a eliminar es el unico elemento de la lista:
	addi $t8, $zero, 1
	
	# ¿numero de elementos NO  es igual a 1? saltamos el if.
	bne $t2,$t8, _endIfNumElemnEqOne
	_ifNumElemnEqOne:
		sw $zero, 0($t0) #Quitamos el inicio
		sw $zero, 4($t0) #Quitamos  el fin
		
		lw $v0, 0($t3)   #Retornamos la posicion del elemento direccionado
		#free($t3)       #Liberamos el espacio ocupado por el nodo.
		j _endDelete	 #Terminamos
	_endIfNumElemnEqOne:
	 
	 
	#Ahora usamos t4 como contador:
	addi $t4, $zero, 1 #t4: contador
	
	#iteramos para encontrar el elemento correcto hasta su posicion anterior
	subi $t1, $t1, 1
	_whileT4NotPrev:	
		bge $t4, $t1, _endWhileT4NotPrev
		add $a0, $zero, $t3 
		jal next 	#next(t3)
		addi $t3, $v0, 0 #t3 = t3.siguiente
		addi $t4, $t4, 1 #t4 += 1
		blt $t4, $t1, _whileT4NotPrev
	_endWhileT4NotPrev:		
	addi $t1, $t1, 1
	
	
	#Encontramos el previo del elemento, ahora guardamos su siguiente.
	add $a0, $zero, $t3 
	jal next
	add $t5, $v0, $zero # t5: elemento a eliminar (t3.next)
	
	# Vemos si tenemos que cambiar la head:
	addi $t8, $zero, 1
	bne $t1, $t8, _endIfPosEqOne # ¿pos != 1? salta el if
	_IfPosEqOne:
		sw $t5, 0($t0)
		#Falta saltar a la parte donde hacemos return
		#Retornamos la posicion direccionada por t3:
		lw $v0, 0($t3)
		#free($t3)
		j _endDelete
	_endIfPosEqOne:
	
	#Vemos si tenemos que cambiar el "fin" de la lista:
	bne $t1, $t2, _ifPosEqLast # ¿pos != 1? salta el if
	_ifPosEqLast:
		sw $t3, 4($t0)
	_endIfPosEqLast:
	
	#Buscamos el siguiente del elemento a eliminar 
	add $a0, $zero, $t5 
	jal next
	add $t6, $zero, $v0 # t6 = elementoAEliminar.next
	
	#Configuramos el siguiente del previo correctamente:
	sw $t6, 4($t3) #elemento.prev.next = elemento.next
	
	
	#Cargamos en v1 la dirección del elemento que era direccionado por el nodo eliminado
	lw $v1, 0($t5)
	
	#NOT YET IMPLEMENTED: liberamos el espacio del nodo:
	#free($t3)
	
	add $v0, $zero, $v1

	_endDelete:
.end_macro


.macro fun_print($nodeDir)
	### DESCRIPCION ###
	# Utilidad auxiliar para imprimir enteros en una lista enlazada.
	
	### ENTRADA ###
	# nodeDir: direccion del nodo que queremos imprimir
	
	### IMPLEMENTACION ###
	# Se carga la direccion almacenada en el nodo, y luego el contenido en esa direccion en a0 y 
	# se imprime.
	
	### --- ###
	
	
	
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
	### ENTRADA ###
	# lista: La direccion de la cabeza de la lista cuyo contenido queremos imprimir
	
	# function: funcion utilizada para imprimir un nodo. Necesitamos diferentes 
	#	 funciones dependiendo del tipo de la lista porque el tipo de dato que almacena esta lista
	# 	 cambia el método de representación.
	
	### Implementacion ###
	# Se guarda una variable con la direccion del  siguiente elemento a imprimir, y mientras esta direccion
	# sea distinta de 0x0, se llama a la funcion de impresion "function" sobre esa direccion, luego se imprime
	# un espacio.
	
	### --- ###
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

	
	#Imprimimos un salto de linea
	la $a0, endln
	addi $v0, $zero, 4
	syscall 
	
	#recuperamos lo guardado
	addi $sp, $sp, 4
	lw $a0, ($sp)
	_endPrint:		
	#return: dirección del nodo siguiente al nodo dado. 
.end_macro


first:
	### DESCRIPCION ###
	# dada la direccion de una lista, imprime el "inicio" de esa lista. (La direccion del primer nodo)
	
	### ENTRADA ###
	#a0: direccion de la lista cuyo primero queremos obtener
	
	### SALIDA ###
	# en v0 se retorna la direccion del primer elemento
	
	### IMPLEMENTACION ###
	# Se carga en v0 la palabra ubicada en la direccion contenida por a0
	
	###---###
	
	lw $v0, 0($a0)
	
	jr $ra
	#return: la dirección del primer elemento

next:

	### DESCRIPCION ###
	# dada la direccion de una lista, imprime el "fin" de esa lista. (La direccion del ultimo nodo)
	
	### ENTRADA ###
	#a0: direccion de la lista cuyo final queremos obtener
	
	### SALIDA ###
	# en v0 se retorna la direccion del ultimo elemento
	
	### IMPLEMENTACION ###
	# Se carga en v0 la palabra ubicada en la direccion (a0) + 4 
	
	###---###

	#Guardamos los registros:
	
	lw $v0, 4($a0)
		
	#volvemos
	jr $ra


end:
	li $v0 10
	syscall
.include 
#push:
     #Template para empilar registros. NO ES UNA FUNCIÓN.
#     sw registro, -0($sp)
#     addi $sp,	$sp, -4