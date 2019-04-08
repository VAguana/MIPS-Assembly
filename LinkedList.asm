#Vamos a definir una linked list:

.data
	#La lista "L" tiene como atributos head y tail.
 	L: .space 4
	L.head: .space 4 
	L.tail: .space 4
	L.nElements: .word 0

#	Forma de una lista: 
#	| 4b:head ptr | 4b: tail ptr | 4b: nElements | 4b: nodeSize |	
	head: .space 4
	tail: .space 4
	
.text

	addi $a0, $zero, 8
	jal NewList
	
	#Asignamos la lista
	sw $v0, L
	
	sw $v0, L.head
	
	sw $v0, L.tail


	
	jal end
	
malloc:
	#aloja una cantidad de espacio almacenada en $a0
	li $v0, 9
	syscall
	jr $ra

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
	jal malloc
	
	#Guardamos este nodo en s1, será el head y la tail de la lista.
	move $s1, $v0
	#Configuramos el siguiente de este nodo como 0 (null)
	addi $v0, $v0, 4
	sw $zero, ($v0)
	
	#Alojamos el espacio para la lista, una lista necesita 16 bytes:
	addi $a0, $zero, 16
	jal malloc
	
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
