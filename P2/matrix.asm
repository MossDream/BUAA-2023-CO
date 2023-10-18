.macro calc_addr(%dst, %row, %column, %rank)
    # dts: the register to save the calculated address
    # row: the row that element is in
    # column: the column that element is in
    # rank: the number of lines(rows) in the matrix
    multu %row, %rank
    mflo %dst
    addu %dst, %dst, %column
    sll %dst, %dst, 2
.end_macro
.data
A: .space 256
B: .space 256
space: .asciiz " "
enter: .asciiz "\n"
.text
# s0->n*n
#s1->n
li $v0,5
syscall
move $s0,$v0
move $s1,$v0
multu $s0,$s0
mflo $s0

#read
for_begin1:
slt $t1,$t0,$s0
beq $t1,0,for_end1

li $v0,5
syscall
sll $t2,$t0,2
sw $v0,A($t2)

addiu  $t0,$t0,1
j for_begin1
for_end1:

li $t0,0
for_begin2:
slt $t1,$t0,$s0
beq $t1,0,for_end2

li $v0,5
syscall
sll $t2,$t0,2
sw $v0,B($t2)

addiu  $t0,$t0,1
j for_begin2
for_end2:

#calculate
# n->s1 row->s2 col->s3 A_element->s4 B_element->s5 result->s6
for_begin3:
slt $t1,$s2,$s1
beq $t1,0,for_end3

li $s3,0
for_begin4:
slt $t2,$s3,$s1
beq $t2,0,for_end4

li $t4,0
li $s6,0
for_begin5:
slt $t3,$t4,$s1
beq $t3,0,for_end5

calc_addr($t5, $s2, $t4, $s1)
lw $s4,A($t5)
calc_addr($t5, $t4, $s3, $s1)
lw $s5,B($t5)
multu $s4,$s5
mflo $t6
addu $s6,$s6,$t6

addiu  $t4,$t4,1
j for_begin5
for_end5:
li $v0,1
move $a0,$s6
syscall
li $v0,4
la $a0,space
syscall

addiu  $s3,$s3,1
j for_begin4
for_end4:
li $v0,4
la $a0,enter
syscall

addiu  $s2,$s2,1
j for_begin3
for_end3:
li $v0,10
syscall