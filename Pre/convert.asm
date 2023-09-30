.data 
matrix:.space 10000
space:.asciiz " "
enter:.asciiz "\n"
.text 
li $v0,5			#read n
syscall 
move $s0,$v0
li $v0,5			#read m
syscall 
move $s1,$v0
li $t0,0			#set i
multu $s0,$s1
mflo $t2

for_begin1:            
slt $t3, $t0, $t2       
beq $t3, $0, for_end1  
li $v0,5
syscall   
sll $t4,$t0,2
sw $v0,matrix($t4) 
addi $t0, $t0, 1       
j for_begin1

for_end1:
move $t0,$s0         #set i
move $t1,$s1			#set j
li $t5,1
for_outer_begin:
beq $t0,0,for_outer_end

for_inner_begin:
beq $t1,0,for_inner_end
multu $s1,$s0
mflo $t4
subu $t4,$t4,$t5
addi $t5,$t5,1
sll $t4,$t4,2
lw $s2,matrix($t4)
beq $s2,0,do_nothing
li $v0,1
move $a0,$t0
syscall
li $v0,4
la $a0,space
syscall
li $v0,1
move $a0,$t1
syscall
li $v0,4
la $a0,space
syscall
li $v0,1
move $a0,$s2
syscall
li $v0,4
la $a0,enter
syscall
do_nothing:
subiu $t1,$t1,1
j for_inner_begin

for_inner_end:
subiu $t0,$t0,1
move $t1,$s1
j for_outer_begin

for_outer_end:
li $v0,10
syscall


