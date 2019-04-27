
init:
	#a0: la cantidad de espacio que vamos a pedir:
	li $v0 9 #Cargamos la instrucción 9
	syscall
	#Guardamos la posicion donde llamaron a init:
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
	#guardamos el espacio pedido
	add $t0, $zero, $a0
	sw $t0, availableSpace
	sw $t0, heapSize	
	
	#Verificamos que el init sea menor a 500 (tamaño heap virtual)
	bgt $t0, 500, _perrorInit
	ble $t0, 500, _initSuccess
	
	_perrorInit:
		li $a0 -1
		jal perror
	
	_initSuccess:
		#Guardamos el inicio de la memoria
		sw $v0 initHead
	
	_endInit:

	#restauramos la posicion donde llamaron a init:
	addi $sp, $sp, 4	
	lw $ra, 0($sp)
	#volvemos
	jr $ra

.globl init

.macro malloc_utilv2($size)
	### ENTRADA ###
	# size: cantidad de bytes que se esperan alojar.
	
	### SALIDA ###
	# Posicion de memoria donde empieza el segmento con la cantidad de bytes pedidos. Si la cantidad
	# pedidda no es múltiplo de 4, se completa con una palabra adicional. (padding)
	
	### ESTRUCTURA ###
	# |-|-|-|3| 1|1|1|1| 1|1|1|1| -|-|-|-3|0|0|0|0|
	# |1w:head| 1w:cont| 1w:cont|  1w:tail|
	# donde la head y la tail contienen el valor n+1, donde n es la cantidad de palabras alojadas
	# por ese malloc. El valor de retorno es la dirección de la primera palabra de contenido.
	
	### IMPLEMENTACION ###	
	# Malloc empieza en el inicio del segmento de memoria y se pregunta si esa palabra es 0 o es distinto
	# si es 0, suma uno al contador de espacio disponible. De lo contrario, reinicia el contador
	# y salta a la siguiente posible direccion disponible. Para saltar, usa el valor contenido 
	# en esa palabra no vacía, pues era un head con la informacion de cuantas palabras alojadas
	# tiene delante. En caso de que el contador nunca alcance la cantidad solicitada, se lanza  un 
	# error por falta de suficiente espacio contiguo.
	
	### --- ###

	addi $t0, $size, 0 # t0: cantidad de bytes a alojar (size)
	
	bnez $t0, _endAllocatedZero
	_allocatedZero:
		addi $v0, $zero, 0 #Se solicitó 0 espacio. Retornamos 0 y devolvemos
		j _endMalloc
	_endAllocatedZero:
	
	#tenemos que calcular la cantidad de palabras que es necesario alojar:
	addi $a0, $t0, 0   # a0 <- size
	addi $a1, $zero, 4 # a1 <- 4
	
	jal mod #v0 <- a0 mod a1 (size mod 4)
	bnez $v0, _SizeMod4NotEqZero
	_SizeMod4EqZero:
		div $t1, $t0, 4 # t1 <- size//4
		j _endIfSizeMod4
		
	_SizeMod4NotEqZero:
		div $t1, $t0, 4 # t1 <- size//4
		addi $t1, $t1, 1 # t1 <- size//4 + 1
	_endIfSizeMod4:
	
	addi $t1, $t1, 2 # t1: cantidad de palabras a alojar (size + 2)
	
	#Buscamos donde alojar:
	lw $t2, initHead    #t2: candidato a posicion donde alojar
	addi $t3, $zero, 1  #t3: contador de espacio disponible
	
	lw $t4, availableSpace # t4 <- availableSpace
	div $t4, $t4, 4        # t4 <- availableSpace // 4
	sub $t4, $t4, $t1      # t4 <- availableSpace // 4 - size - 2
	addi $t4, $t4, 1       # t4 <- availableSpace // 4 - size - 1
	
	subi $t5, $t1, 1       # t5 <- size + 1
	
	addi $t6, $zero, 1     # t6: indice i de los bytes recorridos.
	slt $t7, $t6, $t4      # t7 <- i < availableSpace // 4 - nwords + 1
	sle $t8,$t3, $t5       # t8 <- foundedSize <= size +1
	and $t7, $t7, $t8      # t7 <-  i < availableSpace // 4 - nwords + 1 ^ foundedSize <= size +1
	
	addi $t9, $t2, 0       # t9 <- t2. USaremos t9 para iterar sobre el segmento de memoria
	
	_whileSearchingSpace:
	beqz $t7, _endWhileSearching
		
		lw $t7, 0($t9) # t7 <- (t9) (contenido del iterador de memoria)
		
		#¿La posicion actual de memoria está vacía?
		bnez $t7, _ifWordNotEmpty
		_ifWordIsEmpty:
			addi $t3, $t3, 1 # t3 += 1
			addi $t9, $t9, 4 # t9 = t9.next
			addi $t6, $t6, 1
			j _endIfWordEmpty
		_ifWordNotEmpty:
			addi $t3, $zero, 1  #reiniciamos el contador de espacio encontrado
			addi $t7, $t7, 1   
			add $t6, $t6, $t7   #Saltamos al siguiente índice de la memoria.			
			mul $t7, $t7, 4	    #Saltamos a la siguiente posicion de memoria posiblemente disponible
			add $t2, $t2, $t7  
			add $t9, $t9, $t7   #Movemos el iterador de memoria 
			addi $t2, $t9, 0    #actualizamos el posible candidato a nuevo inicio  
			
		_endIfWordEmpty:
	
		slt $t7, $t6, $t4      # t7 <- i < availableSpace // 4 - nwords + 1
		sle $t8,$t3, $t5       # t8 <- foundedSize <= size +1
		and $t7, $t7, $t8      # t7 <-  i < availableSpace // 4 - nwords + 1 ^ foundedSize <= size +1	
		bnez $t7, _whileSearchingSpace
	
	_endWhileSearching:
	
	#Verificamos si pudimos encontrar una posicion válida:
	beq $t3, $t1, _endNotEnoughMem
	_NotEnoughMem:
		j _endMalloc
	_endNotEnoughMem:
	#Alojamos memoria:
	subi $t1, $t1, 1   #t1 = words + 1
	sw $t1, 0($t2)     #asignamos el valor de la head correctamente
  	addi $t2, $t2, 4   #consideramos el siguiente de la head
  	addi $t3, $zero, 1 #t3: iterador del ciclo. Empieza en 1.
  	addi $t4, $zero, 16843009 # t4: valor que vamos a guardar en cada casilla alojada
  	
  	addi $v0, $t2, 0   #retornamos la posicion de origen del espacio de memoria
  	### NOS QUEDAMOS AQUÍ: falta alojar el espacio que encontramos 
	_allocate:
		bge $t3, $t1,  _endAllocate #i >= words + 1
		
		sw $t4, 0($t2)
		addi $t2, $t2, 4
		addi $t3, $t3, 1
		
		blt $t3, $t1,  _allocate   # i < words + 1
	_endAllocate:
	sub $t1, $zero, $t1  # t1 <-  -(words + 1)
	sw $t1, 0($t2)       # asignamos la tail
	sub $t1, $zero, $t1  # t1 <- (words + 1)   
	addi $t1, $t1, 1     # t1 <- words + 2
	mul $t1, $t1, 4	     # t1: pasamos de palabras a bytes
	
	lw $t2, availableSpace #t2: espacio disponible
	sub $t2, $t2, $t1      #t2: espacio disponible - espacio alojado
	sw $t2, availableSpace # Actualizamos el tamaño disponible
	
	_endMalloc:
.end_macro


.macro free_util($space)

	#Guardamos la head del segmento a eliminar:
	add $t0, $zero, $space
	
	#Guardamos el límite de iteración (contenido del head):
	lw $t1, -1($t0)
	
	#Esto es un if:
	#Revisamos si la posición de memoria ingresada NO es un head:
	sw $a0, 0($sp)
	addi $sp, $sp, -4
	
	sle $a0, $t1, 1
	beq $a0, 1, _perrorFree
	bne $a0, 1, _deleteHead
	
	_perrorFree:
		li $a0 -3
		jal perror
	
	_deleteHead:
		#¿El elemento actual es una head? Entonces comenzamos a liberar el espacio.
		add $t3, $zero, $zero
		sw $t3, -1($t0)

	_whileFree:
		
		#Comenzamos a eliminar la posición deseada
		sw $zero, 0($t0)
		addi $t0, $t0, 4
		
		#Resto 1 al contador de espacio
		subi $t1, $t1, 1
		
		bnez $t1, _whileFree
		
		#Si el free fue exitoso, devuelve 1 en $v0
		li $v0 1

	_endFree:
		#Regreso a $a0 a su valor inicial antes de culminar la funcion
		addi $sp, $sp, 4
		lw $s0, 0($sp)
	
.end_macro


.macro debug.printMalloc($HeadDir)
	# t1 <- HeadDir 
	add $t1,$zero, $HeadDir 
	#Cargamos la head 
	lb $t0, -0($t1)

	#$t2 será el iterador del ciclo:
	addi $t2, $zero, 0
	
	#cargamos en a0 la head
	lb $a0, -0($t1)
	#cargamos en v0 la syscall 1, imprimir entero
	addi $v0, $zero, 1
	syscall
	
	#Movemos la posición de la head:
	addi $t1, $t1, 1
	subi $t0, $t0, 1
	_printMallocWhile:
		lb $a0, -0($t1)
		syscall	
		
		addi $t1, $t1, 1
		addi $t2, $t2, 1
		
		bge $t0, $t2, _printMallocWhile
.end_macro

.macro printHeap_util()
	lw $t0, initHead
	
	lw $t1, heapSize
	sub $t1, $t1, 1
	#$t2 será el iterador del ciclo
	addi $t2, $zero, 0
	
	#Cargamos el syscall 1 (print entero)
	addi $v0, $zero, 1
	
	_printHeapWhile:
		lb $a0, -0($t0)
		syscall
		
		#Movemos la posición
		addi $t0, $t0, 1
		#incrementamos el iterador
		addi $t2, $t2, 1
		
		# Saltamos
		bge $t1, $t2, _printHeapWhile
	#Imprimimos un salto de linea:
	la $a0, endln
	addi $v0, $zero, 4
	syscall
		 	
	
	
.end_macro

.macro debug.printStr()
	la $a0, debugStr
	addi $v0, $zero, 4
	syscall
	
.end_macro


mod:
	#return: a0 mod a1
	div $v0, $a0, $a1 #v0 := a0 // a1
	
	mul  $v0, $v0, $a1 #v0 := v0*a1
	
	sub $v0, $a0, $v0  #v0 := a0 - v0
	
	jr $ra
	
	


free:
	#a0: direccion a liberar
	
	#guardamos:
	sw $ra, 0($sp)
	subi $sp, $sp, 4
	
	#alojamos:
	free_util($a0)
	
	#restauramos:
	addi $sp, $sp, 4
	sw $ra, 0($sp)	
	
	#volvemos:
	jr $ra
	
Debug.PrintHeap:
	printHeap_util()
	jr $ra

malloc:
	#a0: espacio pedido
	
	#guardamos:
	sw $ra, 0($sp)
	subi $sp, $sp, 4
	sw $a1, 0($sp)
	subi $sp, $sp, 4
	
	
	#alojamos:
	malloc_utilv2($a0)
	
	#restauramos:
	addi $sp, $sp, 4
	lw $a1, 0($sp)	
	addi $sp, $sp, 4
	lw $ra, 0($sp)	
	
	#volvemos:
	jr $ra
	
perror:
	beq $a0, -1, print_error_init
	beq $a0, -2, print_error_malloc
	beq $a0, -3, print_error_free

print_error_init:
	la $a0 error_init
	li $v0 4
	syscall

	li $v0 -1

	jr $ra
	
print_error_malloc:
	la $a0 error_malloc
	li $v0 4
	syscall
	
	li $v0 -2

	jr $ra

print_error_free:
	la $a0 error_free
	li $v0 4
	syscall

	li $v0 -3

	jr $ra

.data 
	
	initHead: .word 0 #Head del segmento de memoria pedido
	heapSize: .word 0
	availableSpace: .word 0 #Espacio disponible en cada momento
	debugStr: .asciiz "Debug\n"
	space: .asciiz " "
	endln: .asciiz "\n"


	### Estructura del heap virtual ###
	# |n+1| 1 | 1 | 1 | -(n+1) | 0 | 0 | m + 1 | 1 | 1 | -(m+1) | #
	# Donde, si la posición tiene un número diferente de 1, pasan 3 posibles cosas. Si es 
	# 0, entonces la memoria está disponible. Si no lo es, puede ser un número negativo o 
	# positivo. si es negativo, es una tail, si es positivo, es una head.
	# Una head o una tail tienen valor n+1, donde n es la cantidad de espacio alojado
	# para ese malloc.
	
	error_init: .asciiz "Error. La memoria solicitada supera el almacenamiento del heap"
	error_malloc: .asciiz "Error. No hay espacio suficiendo en memoria para alojas la cantidad solicitada"
	error_free: .asciiz "Error. La dirección ingresada con un un head"
	.globl availableSpace, initHead,debugStr, heapSize, error_init, error_malloc, error_free, space, endln
