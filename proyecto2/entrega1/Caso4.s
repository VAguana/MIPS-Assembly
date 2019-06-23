#Programa:	 myprogs.s
#Autor:	 profs del taller de organizaciòn del computador
#Fecha:	11 Nov 2017

# Obs: Esto es un ejemplo de como podría ser un programa principal a
#	usarse en el proyecto.
# Para la corrida de los proyectos el grupo profesoral generara
# varios archivos con características similares
# Asegurese de crear varios casos de prueba para verificar sus
# implementaciones

#Este archivo fue modificado por algunos errores en su formato y conflictos
# con la implementación del planificador. 
# CAMBIOS:
# .include "myexceptions.s": Comentado. Esto es porque el manejador de casos de prueba
#			     ya lo importa.


	.data
	.globl PROGS
	.globl NUM_PROGS
	.globl QUANTUM

NUM_PROGS:	.word 4
PROGS:		.word p1, p2, p3, p4
QUANTUM: 	.word 5   # En segundos (aproximadamente)
	
m1:	.asciiz "p1 "
m2:	.asciiz "p2 " 
m3:	.asciiz "p3 "
m4:	.asciiz "p4 "
	
	.text

p1:
	li $v0 4
	la $a0 m1
	syscall
	
	beq $zero $zero p1

	li $v0, 10
        syscall
        nop
        nop
	nop
	nop
	nop
	nop
	nop
	nop
	

p2:	
	li $v0 4
	la $a0 m2
	syscall
	
	beq $zero $zero p2

        add $t1, $t1, $t1
	
	li $v0, 10
	syscall
	nop
	nop
	nop
	nop
	nop
	nop


	
p3:	
	li $v0 4
	la $a0 m3
	syscall
	
	add $t1 $t2 $t3

	beq $zero $zero p3

	li $v0, 10
	syscall
	nop
	nop
	nop
	nop
	nop
	nop
	

p4:	
	li $v0 4
	la $a0 m4
	syscall
	
	add $t1 $t2 $t3

	beq $zero $zero p4

	li $v0, 10
	syscall
	nop
	nop
	nop
	nop
	nop
	nop
	
	#.include "myexceptions.s"
