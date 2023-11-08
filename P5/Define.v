// Purpose: Define the constant value of the MIPS instruction set

//R-type
//op[5:0]
`define R 6'b000000
//fn[5:0]
`define add 6'b100000
`define sub 6'b100010
`define jr 6'b001000

// others
//op[5:0]
`define lw 6'b100011
`define sw 6'b101011
`define beq 6'b000100
`define lui 6'b001111
`define ori 6'b001101
`define jal 6'b000011
`define j 6'b000010

// segment
`define fn 5:0
`define op 31:26
`define rs 25:21
`define rt 20:16
`define rd 15:11
`define addr26 25:0
`define imm16 15:0
