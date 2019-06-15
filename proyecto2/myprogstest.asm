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

NUM_PROGS:	.word 2
PROGS:		.word p1, p2
QUANTUM: 	.word 5   # En segundos (aproximadamente)
	
m1:	.asciiz "p1\n"
m2:	.asciiz "p2\n" 
m3:	.asciiz "p3\n"
	
	.text
	
p1:
	addi $s0, $s0, 1
	addi $s0, $s0, 1
	add $s0, $s0, $s0
			
	li $v0, 10
	syscall
	
	nop

p2:
	
	addi $s0, $s0, 1
	addi $s0, $s0, 1
	addi $s0, $s0, 1
			
	li $v0, 10
	syscall
	
	nop