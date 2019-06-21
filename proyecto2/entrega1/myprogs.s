#Programa:	 myprogs.s
#Autor:	 profs del taller de organizaciòn del computador
#Fecha:	 Junio 2019

# Obs: Esto es un ejemplo de como podría ser un programa principal a
#	usarse en el proyecto.
# Para la corrida de los proyectos el grupo profesoral generara
# varios archivos con características similares
# Asegurese de crear varios casos de prueba para verificar sus
# implementaciones
		
	.data
	.globl PROGS
	.globl NUM_PROGS
	.globl QUANTUM

NUM_PROGS:	.word 4
PROGS:		.word p1, p2, p3, p4
QUANTUM: 	.word 5   # En segundos (aproximadamente)
	
m1:	.asciiz "p1\n"
m2:	.asciiz "p2\n" 
m3:	.asciiz "p3\n"
m4:	.asciiz "p4\n"	
	.text

p1:
	li $v0 4
	la $a0 m1
	syscall
	

	li $v0, 10
        syscall
	

p2:	
	li $v0 4
	la $a0 m2
	syscall
	
	li $t9, 0
	add $t9, $zero, $zero
	add $t9, $zero, $zero
	addi $t9, $zero, 0
	addi $t9, $zero, 0
	addi $t9, $zero, 0
	addi $t9, $zero, 0
	addi $t9, $zero, 0
	addi $t9, $zero, 0
	addi $t9, $zero, 0
								
	beq $zero, $zero, p2


	
	li $v0, 10
	syscall
	nop
	nop

p3:	
	li $v0 4
	la $a0 m3
	syscall
	add $t8, $zero, $zero


	li $v0, 10
	syscall
	nop
	
p4:	
	li $v0 4
	la $a0 m4
	syscall
	add $t8, $zero, $zero

	beq $zero, $zero, p4

	li $v0, 10
	syscall
	nop	

