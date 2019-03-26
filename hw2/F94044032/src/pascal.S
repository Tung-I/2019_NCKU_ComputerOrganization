main:
    addi $a0, $zero, 10 # n = 10
    addi $a1, $zero, 5  # m = 5
    addi $v0, $zero, 1
    jal pascal          # call pascal(10, 5)
    j exit

pascal:
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $t1, 4($sp)
	sw $t0, 0($sp)
	
	beq $a1, $zero, pexit
	beq $a0, $a1, pexit
	
	add $t0, $zero, $a0
	add $t1, $zero, $a1
	addi $a0, $t0, -1
	addi $a1, $t1, -1
	jal pascal
	
	addi $a0, $t0, -1
	add $a1, $t1, $zero
	jal pascal
	
	addi $v0, $v0, 1

pexit:
	lw $ra, 8($sp)
	lw $t1, 4($sp)
	lw $t0, 0($sp)
	addi $sp, $sp, 12
	jr $ra
		

exit:
