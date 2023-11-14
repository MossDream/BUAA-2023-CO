// Purpose: Define the constant value of the MIPS instruction set

//R-type
//op[5:0]
`define R 6'b000000
//fn[5:0]
// calr 
`define Add 6'b100000
`define Addu 6'b100001
`define Sub 6'b100010
`define Subu 6'b100011

`define And 6'b100100
`define Or 6'b100101
`define Nor 6'b100111
`define Xor 6'b100110 

`define Sll 6'b000000
`define Sllv 6'b000100
`define Slt 6'b101010
`define Sltu 6'b101011
`define Sra 6'b000011
`define Srav 6'b000111
`define Srl 6'b000010
`define Srlv 6'b000110

//jump1
`define Jr 6'b001000
`define Jalr 6'b001001

//readhl
`define Mfhi 6'b010000
`define Mflo 6'b010010

//writehl
`define Mthi 6'b010001
`define Mtlo 6'b010011

//calmudi
`define Mult 6'b011000
`define Multu 6'b011001
`define Div 6'b011010
`define Divu 6'b011011

//I
//op[5:0]
//load
`define Lw 6'b100011
`define Lb 6'b100000
`define Lbu 6'b100100
`define Lh 6'b100001
`define Lhu 6'b100101

//store
`define Sw 6'b101011
`define Sb 6'b101000
`define Sh 6'b101001

//branch
`define Beq 6'b000100
`define Bne 6'b000101
`define Bgtz 6'b000111
`define Blez 6'b000110
`define BgezOrBltz 6'b000001  

//these two need nInstr[20:16] to identify
// nInstr[20:16]
`define Bgez 5'b00001
`define Bltz 5'b00000

//cali
`define Lui 6'b001111
`define Ori 6'b001101
`define Addi 6'b001000
`define Addiu 6'b001001
`define Andi 6'b001100
`define Xori 6'b001110
`define Slti 6'b001010
`define Sltiu 6'b001011

//J
//op[5:0]
// jump2
`define Jal 6'b000011
`define J 6'b000010

// segment
`define fn 5:0
`define op 31:26
`define rs 25:21
`define rt 20:16
`define rd 15:11
`define addr26 25:0
`define imm16 15:0
`define shamt 10:6
