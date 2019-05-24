#Test 6:

.data
	ln: .asciiz "\n"

.text
#Inicializamos 500
addi $a0, $zero, 500
jal init

#PEdimos 400:
addi $a0, $zero, 400
jal malloc

#Vamos a generar 100 enteros. 
# $t0: contador:
# $t1: direcci�n donde alojar 
# $t2: l�mite de iteraci�n
addi $t0, $zero, 1
add $t1, $zero, $v0
addi $t2, $zero, 400

For1to400:
	sw $t0, 0($t1)
	addi $t0, $t0, 1
	addi $t1, $t1, 4
	ble  $t0, $t2, For1to400

#Vamos a imprimir 100 enteros. 
# $t0: contador:
# $t1: direcci�n donde alojar 
# $t2: l�mite de iteraci�n
addi $t0, $zero, 1
add $t1, $zero, $v0
addi $t2, $zero, 400

Print1to400:
	lw $a0, 0($t1)
	li $v0, 1
	syscall
	
	la $a0, ln
	li $v0, 4
	syscall
	
	addi $t0, $t0, 1
	addi $t1, $t1, 4
	ble  $t0, $t2, Print1to400

#Oedimos 120:
addi $a0, $zero, 120
jal malloc

#Pedimos 100:
addi $a0, $zero, 100
jal malloc
#Liberamos el de 100
add $a0, $zero,$v0
jal free
#Pedimos 50:
addi $a0, $zero, 50
jal malloc

addi $v0, $zero, 10
syscall

.include "linked-list.asm"
