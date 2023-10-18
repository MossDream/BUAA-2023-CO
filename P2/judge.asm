.data
str:.space 20
t: .asciiz "1"
f: .asciiz "0"
.text
# s0->n s1->low s2->high
li $v0,5
syscall
move $s0,$v0

for_begin:
slt $t1,$t0,$s0
beq $t1,0,for_end

li $v0,12
syscall
sb $v0,str($t0)

addiu  $t0,$t0,1
j for_begin
for_end:

li $s1,0
sub $s2,$s0,1
li $t0,0
for_begin1:
slt $t1,$t0,$s0
beq $t1,0,for_end1

lb $t2,str($s1)
lb $t3,str($s2)
bne $t2,$t3,false
addiu $s1,$s1,1
subiu $s2,$s2,1

addiu  $t0,$t0,1
j for_begin1
for_end1:

li $v0,4
la $a0,t
syscall
j end
false:
li $v0,4
la $a0,f
syscall
end:
li $v0,10
syscall