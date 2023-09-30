.text 
li $v0,5			#read n
syscall 
move $t0,$v0
li $t1,100
li $t2,400
li $t3,4
divu $t0,$t2
mfhi $s0
beq $s0,0,isleap
divu $t0,$t3
mfhi $s0
beq $s0,0,isleap_pre

notleap:
li $a0 0
li $v0 1
syscall

end:
li $v0, 10
syscall

isleap_pre:
divu $t0,$t1
mfhi $s0
bne $s0,0,isleap
j notleap

isleap:
li $a0 1
li $v0 1
syscall
j end