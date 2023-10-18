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

.macro push(%src)
    sw      %src, 0($sp)
    subi    $sp, $sp, 4
.end_macro

.macro pop(%des)
    addi    $sp, $sp, 4
    lw      %des, 0($sp) 
.end_macro

.data
symbol: .space 28
array: .space 28
space: .asciiz " "
enter: .asciiz "\n"

.text
main:
#n->s0 cnt->s1
getInt($s0)
jal FA
end

FA:
#arg(index)->t0 i->t1
push($ra)
push($t0)
push($t1)

beq $s1,0,skip2
addiu $t0,$t0,1

skip2:
addiu $s1,$s1,1
slt $t2,$t0,$s0
beq $t2,1,skip
li $t1,0
for_begin1:
slt $t2,$t1,$s0
beq $t2,0,for_end1

sll $t2,$t1,2
lw $t3,array($t2)
printInt($t3)
li $v0,4
la $a0,space
syscall

addiu  $t1,$t1,1
j for_begin1
for_end1:
li $v0,4
la $a0,enter
syscall
pop($t1)
pop($t0)
pop($ra)
jr $ra


skip:
li $t1,0
for_begin2:
slt $t2,$t1,$s0
beq $t2,0,for_end2

sll $t2,$t1,2
lw $t3,symbol($t2)
bne $t3,0,skip_1

addiu $t4,$t1,1
sll $t2,$t0,2
sw $t4,array($t2)
sll $t2,$t1,2
li $t4,1
sw $t4,symbol($t2)
jal FA
sll $t2,$t1,2
li $t4,0
sw $t4,symbol($t2)

skip_1:
addiu  $t1,$t1,1
j for_begin2
for_end2:


pop($t1)
pop($t0)
pop($ra)
jr $ra
