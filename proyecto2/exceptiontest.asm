
.macro what()
	addi $s3, $zero, 5
.end_macro

.ktext 0x80000180
	addi $s1, $zero, 1
	
	mfc0 $t1, $14

	srl $t1, $t1, 6
	
	what()
	
	sw $14, lol
	
	
	mfc0 $t0, $14
	addi $t0, $t0, 4
	mtc0 $t0, $14
	eret
.data
	lol: .word 0
.text
	break 0x20
	
	
	addi $s0, $zero, 1
	
	addi $v0, $zero, 10
	syscall
	
#.include "myexceptions.s"
