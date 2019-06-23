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
	
p1:	li $t1 1
	li $t2 1	
	li $t3 4	
p1l:
	li $v0 4
	la $a0 m1
	syscall

        add $t1, $t1, $t2

	beq $t1 $t3 p1e
	beq $zero $zero p1l
p1e:		
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

p2:	li $t1 1
	li $t2 1	
	li $t3 6	
p2l:
	li $v0 4
	la $a0 m2
	syscall

        add $t1, $t1, $t2

	beq $t1 $t3 p2e
	beq $zero $zero p2l
p2e:		
	li $v0, 10
	syscall
	nop
	nop
	nop
	nop
	nop
	nop
	
	#.include "myexceptions.s"
