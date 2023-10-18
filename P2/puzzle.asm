#  This is most standard version of function call use.
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
maze:.space 256
visit: .space 256

.text
# n->s0 m->s1 sx->s2 sy->s3 ex->s4 ey->s5 cnt->s6 n*m->s7
main:
#read:n m
getInt($s0)
getInt($s1)
#read:maze
multu $s0,$s1
mflo $s7
for_begin1:
slt $t1,$t0,$s7
beq $t1,0,for_end1

li $v0,5
syscall
sll $t2,$t0,2
sw $v0,maze($t2)

addiu  $t0,$t0,1
j for_begin1
for_end1:
#read: pos
getInt($s2)
getInt($s3)
getInt($s4)
getInt($s5)

subu $t3,$s2,1
subu $t4,$s3,1
move $a0,$t3
move $a1,$t4
jal dfs

printInt($s6)
end

dfs:
# arg: x->a0,t0 y->a1,t1
push($ra)
push($t0)
push($t1)

# load argument
move $t0,$a0
move $t1,$a1

# x<0
slt $t2,$t0,$zero
beq $t2,1,return_1
# x>=n
slt $t2,$t0,$s0
beq $t2,0,return_1
# y<0
slt $t2,$t1,$zero
beq $t2,1,return_1
# y>=m
slt $t2,$t1,$s1
beq $t2,0,return_1
# maze[x][y]==1
calc_addr($t2, $t0, $t1, $s1)
lw $t3,maze($t2)
beq $t3,1,return_1
# visit[x][y]==1
calc_addr($t2, $t0, $t1, $s1)
lw $t3,visit($t2)
beq $t3,0,not_return_1

return_1:
pop($t1)
pop($t0)
pop($ra)
jr $ra

not_return_1:
subu $t2,$s4,1
subu $t3,$s5,1
bne $t0,$t2,not_return_2
bne $t1,$t3,not_return_2

return_2:
addiu $s6,$s6,1
pop($t1)
pop($t0)
pop($ra)
jr $ra

not_return_2:
calc_addr($t2, $t0, $t1, $s1)
li $t3,1
sw $t3,visit($t2)

move $a0,$t0
addiu $t2,$t1,1
move $a1,$t2
jal dfs
move $a0,$t0
subiu $t2,$t1,1
move $a1,$t2
jal dfs
move $a1,$t1
addiu $t2,$t0,1
move $a0,$t2
jal dfs
move $a1,$t1
subiu $t2,$t0,1
move $a0,$t2
jal dfs

calc_addr($t2, $t0, $t1, $s1)
li $t3,0
sw $t3,visit($t2)

pop($t1)
pop($t0)
pop($ra)
jr $ra