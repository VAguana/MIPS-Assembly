#Test 6:

.text
#Inicializamos 500
addi $a0, $zero, 500
jal init

#PEdimos 400:
addi $a0, $zero, 300
jal malloc

#Vamos a generar 100 enteros. 
# $t0: contador:
# $t1: dirección donde alojar 
# $t2: límite de iteración
addi $t0, $zero, 1
add $t1, $zero, $v0
addi $t2, $zero, 400

#For1to400:
#	sw $t0, 0($t1)
#	addi $t0, $zero, 1
#	addi $t1, $zero, 4
#	ble  $t0, $t2, For1to400

#Vamos a imprimir 100 enteros. 
# $t0: contador:
# $t1: dirección donde alojar 
# $t2: límite de iteración
addi $t0, $zero, 1
add $t1, $zero, $v0
addi $t2, $zero, 400
#For1to400:
#	lw $a0, 0($t1)
#	addi $v0, $zer0, 4
#	syscall
#	addi $t0, $zero, 1
#	addi $t1, $zero, 4
#	ble  $t0, $t2, For1to400

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
