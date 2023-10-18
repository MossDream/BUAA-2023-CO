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
f: .space 400
h: .space 400
space: .asciiz " "
enter: .asciiz "\n"
.text
# s0->m1 s1->n1 s2->m2 s3->n2
# read_1
li $v0,5
syscall
move $s0,$v0
li $v0,5
syscall
move $s1,$v0
li $v0,5
syscall
move $s2,$v0
li $v0,5
syscall
move $s3,$v0
#read_2
# s4->m1*n1 s5->m2*n2
multu $s0,$s1
mflo $s4
multu $s2,$s3
mflo $s5

for_begin1:
slt $t1,$t0,$s4
beq $t1,0,for_end1

li $v0,5
syscall
sll $t2,$t0,2
sw $v0,f($t2)

addiu  $t0,$t0,1
j for_begin1
for_end1:

li $t0,0
for_begin2:
slt $t1,$t0,$s5
beq $t1,0,for_end2

li $v0,5
syscall
sll $t2,$t0,2
sw $v0,h($t2)

addiu  $t0,$t0,1
j for_begin2
for_end2:


#calculate
# s4->m1-m2+1 s5->n1-n2+1
subu $s4,$s0,$s2
addiu $s4,$s4,1
subu $s5,$s1,$s3
addiu $s5,$s5,1

#s6->row s7->col t9->result
for_begin3:
slt $t1,$s6,$s4
beq $t1,0,for_end3

li $s7,0
for_begin4:
slt $t2,$s7,$s5
beq $t2,0,for_end4
#
li $t4,0
li $t9,0
for_begin5:
slt $t3,$t4,$s2
beq $t3,0,for_end5

li $t5,0
for_begin6:
slt $t3,$t5,$s3
beq $t3,0,for_end6



addu $t7,$s6,$t4
addu $t8,$s7,$t5
calc_addr($t6, $t7, $t8, $s1)
lw $t7,f($t6)
calc_addr($t6, $t4, $t5, $s3)
lw $t8,h($t6)
multu $t7,$t8
mflo $t6
addu $t9,$t9,$t6


addiu  $t5,$t5,1
j for_begin6
for_end6:

addiu  $t4,$t4,1
j for_begin5
for_end5:
li $v0,1
move $a0,$t9
syscall
li $v0,4
la $a0,space
syscall
#
addiu  $s7,$s7,1
j for_begin4
for_end4:
li $v0,4
la $a0,enter
syscall

addiu  $s6,$s6,1
j for_begin3
for_end3:

li $v0,10
syscall