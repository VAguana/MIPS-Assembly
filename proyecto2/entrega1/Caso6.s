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
# PROGS: Originalmente estaba como "PROGS:.word p2, p2", ahora se modifico como "PROGS:.word p1, p2"

# .include "myexceptions.s": Comentado. Esto es porque el manejador de casos de prueba
#			     ya lo importa.

	.data
	.globl PROGS
	.globl NUM_PROGS
	.globl QUANTUM

NUM_PROGS:	.word 2
PROGS:		.word p1, p2
QUANTUM: 	.word 5   # En segundos (aproximadamente)
	
m1:	.asciiz "abcdefghijklmnopqrstuvwxyz\n"
m2:	.asciiz "ABCDEFGHIJKLMNOPQRSTUVWXYZ\n"
	
	.text

p1:
	lb  $2 m1 + 0	
	lb  $3 m1 + 1	
	lb  $4 m1 + 2	
	lb  $5 m1 + 3	
	lb  $6 m1 + 4	
	lb  $7 m1 + 5	
	lb  $8 m1 + 6	
	lb  $9 m1 + 7	
	lb $10 m1 + 8
	lb $11 m1 + 9
	lb $12 m1 + 10
	lb $13 m1 + 11
	lb $14 m1 + 12
	lb $15 m1 + 13
	lb $16 m1 + 14
	lb $17 m1 + 15
	lb $18 m1 + 16
	lb $19 m1 + 17
	lb $20 m1 + 18
	lb $21 m1 + 19
	lb $22 m1 + 20
	lb $23 m1 + 21
	lb $24 m1 + 22
	lb $25 m1 + 23
        #lb $26 m1 + 8
        #lb $27 m1 + 8
	lb $28 m1 + 24
	lb $29 m1 + 25
	lb $30 m1 + 26
	lb $31 m1 + 27
	
	sb  $2 m1 + 0	
	sb  $3 m1 + 1	
	sb  $4 m1 + 2	
	sb  $5 m1 + 3	
	sb  $6 m1 + 4	
	sb  $7 m1 + 5	
	sb  $8 m1 + 6	
	sb  $9 m1 + 7	
	sb $10 m1 + 8
	sb $11 m1 + 9
	sb $12 m1 + 10
	sb $13 m1 + 11
	sb $14 m1 + 12
	sb $15 m1 + 13
	sb $16 m1 + 14
	sb $17 m1 + 15
	sb $18 m1 + 16
	sb $19 m1 + 17
	sb $20 m1 + 18
	sb $21 m1 + 19
	sb $22 m1 + 20
	sb $23 m1 + 21
	sb $24 m1 + 22
	sb $25 m1 + 23
        #sb $26 m1 + 8
        #sb $27 m1 + 8
	sb $28 m1 + 24
	sb $29 m1 + 25
	sb $30 m1 + 26
	sb $31 m1 + 27

	li $v0, 4
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
	lb  $2 m2 + 0	
	lb  $3 m2 + 1	
	lb  $4 m2 + 2	
	lb  $5 m2 + 3	
	lb  $6 m2 + 4	
	lb  $7 m2 + 5	
	lb  $8 m2 + 6	
	lb  $9 m2 + 7	
	lb $10 m2 + 8
	lb $11 m2 + 9
	lb $12 m2 + 10
	lb $13 m2 + 11
	lb $14 m2 + 12
	lb $15 m2 + 13
	lb $16 m2 + 14
	lb $17 m2 + 15
	lb $18 m2 + 16
	lb $19 m2 + 17
	lb $20 m2 + 18
	lb $21 m2 + 19
	lb $22 m2 + 20
	lb $23 m2 + 21
	lb $24 m2 + 22
	lb $25 m2 + 23
        #lb $26 m2 + 8
        #lb $27 m2 + 8
	lb $28 m2 + 24
	lb $29 m2 + 25
	lb $30 m2 + 26
	lb $31 m2 + 27
	
	sb  $2 m2 + 0	
	sb  $3 m2 + 1	
	sb  $4 m2 + 2	
	sb  $5 m2 + 3	
	sb  $6 m2 + 4	
	sb  $7 m2 + 5	
	sb  $8 m2 + 6	
	sb  $9 m2 + 7	
	sb $10 m2 + 8
	sb $11 m2 + 9
	sb $12 m2 + 10
	sb $13 m2 + 11
	sb $14 m2 + 12
	sb $15 m2 + 13
	sb $16 m2 + 14
	sb $17 m2 + 15
	sb $18 m2 + 16
	sb $19 m2 + 17
	sb $20 m2 + 18
	sb $21 m2 + 19
	sb $22 m2 + 20
	sb $23 m2 + 21
	sb $24 m2 + 22
	sb $25 m2 + 23
        #sb $26 m2 + 8
        #sb $27 m2 + 8
	sb $28 m2 + 24
	sb $29 m2 + 25
	sb $30 m2 + 26
	sb $31 m2 + 27

	li $v0 4
	la $a0 m2
	syscall
	
	beq $zero $zero p2

	
	li $v0, 10
	syscall
	nop
	nop
	nop
	nop
	nop
	nop



	
	#.include "myexceptions.s"
