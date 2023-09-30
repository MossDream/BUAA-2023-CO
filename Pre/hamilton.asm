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

.macro getOffset(%ans,%i,%j)
    sll %ans,%i,3
    addu %ans,%ans,%j
    sll %ans,%ans,2 
.end_macro

.data 
G:.space 256
book:.space 32
# m-->s0 n-->s1 ans-->s2
# i-->t0 x-->t1 y-->t2 
.text
main:
getInt($s1)
getInt($s0)

li $t0,0
move $t3,$s0

for_begin1:            
slt $t4, $t0, $t3       
beq $t4, $0, for_end1 

getInt($t1)
getInt($t2)

subiu $t5,$t1,1
subiu $t6,$t2,1
getOffset($t7,$t5,$t6)
li $t8,1
sw $t8,G($t7)
getOffset($t7,$t6,$t5)
sw $t8,G($t7)

addi $t0, $t0, 1       
j for_begin1

for_end1:
li $a0,0
jal dfs
printInt($s2)
end

dfs:
#argument-->t0 flag-->t3 i-->t4
push($ra)
push($t0)
push($t4)
move $t0,$a0

li $t1,1
sll $t2,$t0,2
sw $t1,book($t2)

li $t3,1
li $t4,0
for_begin_2:
slt $t5,$t4,$s1
beq $t5,$0,for_end_2

sll $t2,$t4,2
lw $t1,book($t2)
and $t3,$t3,$t1

addi $t4, $t4, 1       
j for_begin_2

for_end_2:
beq $t3,0,skip_1

getOffset($t2,$t0,$0)
lw $t1,G($t2)
beq $t1,0,skip_1

li $s2,1

pop($t4)
pop($t0)
pop($ra)
jr $ra

skip_1:
li $t4,0
for_begin_3:
slt $t5,$t4,$s1
beq $t5,$0,for_end_3

getOffset($t2,$t0,$t4)
lw $t1,G($t2)
beq $t1,0,skip_2
sll $t2,$t4,2
lw $t1,book($t2)
beq $t1,1,skip_2
move $a0,$t4
jal dfs

skip_2:
addi $t4, $t4, 1       
j for_begin_3

for_end_3:
li $t1,0
sll $t2,$t0,2
sw $t1,book($t2)
pop($t4)
pop($t0)
pop($ra)
jr $ra
