.macro end
    li      $v0, 10
    syscall
.end_macro

.macro getInt(%des)
    li      $v0, 5
    syscall
    move    %des, $v0
.end_macro

.macro printInt(%src)
    move    $a0, %src
    li      $v0, 1
    syscall
.end_macro

.data
f: .space 4000

.text
main:
# len->s0 n->s1 n+1->s2 carry->s3 s->s4 len+1->s5
getInt($s1)

li $t0,1
sw $t0,f($zero)

li $t0,2
addiu $s2,$s1,1
for_begin1:
slt $t1,$t0,$s2
beq $t1,0,for_end1

li $s3,0
li $t3,0
addiu $s5,$s0,1
for_begin2:
slt $t1,$t3,$s5
beq $t1,0,for_end2

sll $t4,$t3,2
lw $t5,f($t4)
multu $t5,$t0
mflo $s4
addu $s4,$s4,$s3
li $t5,10
divu $s4,$t5
mflo $s3
mfhi $t6
sw $t6,f($t4)


addiu  $t3,$t3,1
j for_begin2
for_end2:

while_begin:
beq $s3,0,while_end

addiu $s0,$s0,1
li $t5,10
divu $s3,$t5
mfhi $t7
sll $t6,$s0,2
sw $t7,f($t6)
mflo $s3 

j while_begin
while_end:


addiu  $t0,$t0,1
j for_begin1
for_end1:

move $t0,$s0
for_begin3:
slt $t1,$t0,$zero
beq $t1,1,for_end3

sll $t4,$t0,2
lw $t5,f($t4)
printInt($t5)

subiu  $t0,$t0,1
j for_begin3
for_end3:
end