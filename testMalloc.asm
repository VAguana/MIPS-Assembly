
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
	# size: cantidad de bytes que vamos a alojar
	
	addi $t0, $size, 0 # t0: cantidad de bytes a alojar (size)
	#tenemos que calcular la cantidad de palabras que es necesario alojar:
	addi $a0, $t0, 0   # a0 <- size
	addi $a1, $zero, 4 # a1 <- 4
	
	jal mod #v0 <- a0 mod a1 (size mod 4)
	bnez $v0, 
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
	
	addi $t9, $t4, 0       # t9 <- t4. USaremos t9 para iterar sobre el segmento de memoria
	
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
			addi $t3, $zero, 1 #reiniciamos el contador de espacio encontrado
			addi $t7, $t7, 1   
			mul $t7, $t7, 4	   #Saltamos a la siguiente posicion de memoria posiblemente disponible
			add $t2, $t2, $t7  
			add $t6, $t6, $t7  #Saltamos al siguiente índice de la memoria.
			
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
	subi $t1, $t1, 1 #t1 = words - 1
	sw $t1, 0($t2)   #asignamos el valor de la head correctamente
  	addi $t2, $t2, 4 #consideramos el siguiente de la head
  	
  	### NOS QUEDAMOS AQUÍ: falta alojar el espacio que encontramos 
	
	
	_endMalloc:
.end_macro


.macro malloc_util($size)
	#guardamos el tamaño a alojar  en t0:
	add $t0, $zero, $size
	div $t0, $t0, 4
	#A continuación, vamos a buscar el espacio donde alojar:
	#Guardamos en t1 el la cantidad de palabras que tenemos que buscar (es size/4 si size es 
	# divisible entre 4, o size // 2 + 1 si no lo es.):
	addi $a0, $t0, 0
	addi $a1, $zero, 4
	
	jal mod #v0 := size mod 4
	
	
	#¿size mod  4 != 0? vamos a la segunda etiqueta
	bnez $v0, _ifSizeMod4NotEqZero
	_ifSizeMod4EqZero:
		#La cantidad de palabras a alojar es size/4
		div $t1, $t0, 4
		j _endIfSizeMod4
		
	_ifSizeMod4NotEqZero:
		#La cantidad de palabras a alojar es size/4 + 1
		div $t1, $t0, 4
		addi $t1, $t1, 1 			
	_endIfSizeMod4:
	#t1: cantidad de bytes a alojar
	addi $t1, $t1, 2 # +2 por la head y la tail
	
	#Ahora guardamos en t2 el límite de iteración. Vamos a iterar hasta: availableSpace - size - 1
	lw $t2, availableSpace
	div $t2, $t2, 4 #t2 := cantidad de bytes disponibles
	sub $t2,$t2,$t1
	#Como t1 es size + 2, tenemos que sumar 1 para que sea size + 1
	addi $t2, $t2, 1
	#En t3 vamos a llevar un contador de cuanto espacio disponible tenemos para poder alojar:
	addi $t3, $zero, 0
	#en t4 tenemos el inicio de la memoria:
	lw $t4, initHead
	
	#En t6 tenemos el iterador del ciclo
	addi $t6, $zero, 0
	
	#En t7 está el candidato a posible posición de malloc
	move $t7, $t4
	
	_mallocWhile:
		#Esto es un if:
		#Cargamos en t5 el contenido de la t4-esima posición
		lw $t5, -0($t4)
		beq $t5,$zero,_keepCounting
		bne $t5,$zero,_jumpToNext
		
		_jumpToNext:
			# ¿el elemento actual de la memoria es distinto de 1 y de 0?
			# Entonces es una head, saltamos el espacio alojado a esa head.
			
			#Adelantamos el iterador t6 hasta uno más de la tail
			add $t6,$t6,$t5
			addi $t6,$t6,1
			
			#Reiniciamos el contador t3 de espacio disponible:
			addi $t3, $zero, 0
			
			#Movemos la posición del arreglo hasta 1 más de la posición de la tail
			add $t4, $t4, $t5
			addi $t4, $t4, 4
			
			#configuramos el candidato a posición de malloc t7 como el tail+1
			move $t7, $t4
			j _endMallocIf0
		
		_keepCounting:
			#¿El elemento actual es == 0? Entonces sigue contando.
			addi $t3, $t3, 1
			addi $t6, $t6, 1
			
			#movemos el apuntador a la dirección de memoria:
			addi $t4, $t4, 4
			j _endMallocIf0
			
		_endMallocIf0:
	
		#¿Terminamos el ciclo? Para terminar se tiene que cumplir que ($t3)==($t1) O ($t6)>=(avaibleSpace)

		slt $t8, $t3, $t1 # t8 = ¿($t3)<($t1)//espacio a alojar? 
		slt $t9, $t6, $t2 # t9 = ¿($t6)<(limiteDeIteracion) ?
		and $t8, $t8, $t9 # t8 = ¿($t3)<($t1) && ($t6)<(limiteDeIteracion)?
		beq $t8,1, _mallocWhile # ¿($t3)<($t1) && ($t6)<(limiteDeIteracion)==True? entonces vuelve al ciclo.
	
	#Terminamos el ciclo, vemos si pudimos alojar:
	bne $t3, $t1, _perrorMalloc #¿ t3 < t1 (espacio contiguo disponible < espacio necesitado) ? Termina con un error 
	bge $t3, $t1, _allocate
	
	_perrorMalloc:
		li $a0 -2
		jal perror
	
	_allocate:
		#Configuramos el head:
		subi $t1, $t1, 1 # t1: cantidad de bytes disponibles + 1
		sw $t1, -0($t7)
		addi $t3, $zero, 1 # t3 será nuestra variable de iteración.
		addi $t7, $t7,4 #El ciclo empieza en head + 1
		add $v0, $zero, $t7 #hacemos "return t7", dado que en t7 está la posición de la memoria donde empieza		
		addi $t8, $zero, 16843009 #El número que vamos a guardar en cada casilla
		
		_allocateWhile:
			sw $t8, -0($t7)
			addi $t3, $t3, 1 #aumentamos la variable de iteración
			addi $t7, $t7, 4 #movemos la posición donde estamos alojando.
			
			sle $t6, $t3, $t0 # t6 := t3 <= $size (espacio alojado <= espacio a alojar)
			beq $t6, 1, _allocateWhile # ¿(espacio alojado <= espacio a alojar)==True? Entonces vuelve al ciclo
		
		#Salimos del ciclo, vamos a configurar la tail:
		sub $t0, $zero, $t0
		sw $t0, -0($t7)
		
		#Si el malloc fue exitoso, devuelve 1 en $v0
		#li $v0 1
		
	_endMalloc:
		

.end_macro


.macro free_util($space)

	#Guardamos la head del segmento a eliminar:
	add $t0, $zero, $space
	
	#Guardamos el límite de iteración:
	lb $t1, -1($t0)
	
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
		addi $t3, $zero, 0
		sb $t3, -1($t0)

	_whileFree:
		
		#Comenzamos a eliminar la posición deseada
		sb $zero, 0($t0)
		addi $t0, $t0, 1
		
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
	
	#alojamos:
	malloc_util($a0)
	
	#restauramos:
	addi $sp, $sp, 4
	sw $ra, 0($sp)	
	
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
