`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:58:42 10/31/2023 
// Design Name: 
// Module Name:    Controller 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "Define.v"
module Controller (
    input  [31:0] nInstr,
    input  [ 5:0] op,
    input  [ 5:0] fn,
    output [ 1:0] regDst,
    output        aluSrc,
    output        regWrite,
    output        memRead,
    output        memWrite,
    output [ 2:0] memToR,
    output [ 1:0] extOp,
    output [ 2:0] branchType,
    output [ 2:0] jumpOp,
    output [ 3:0] aluOp,
    output        isShamt,
    output [ 2:0] mudiOp,
    output        hiWrite,
    output        loWrite,
    output        hiRead,
    output        loRead,
    output        start,
    output [ 2:0] loadOp,
    output [ 1:0] storeOp
);

  // for identify Bgez and Bltz
  wire nInstr_20_16;
  assign nInstr_20_16 = nInstr[20:16];

  // all instrs
  // calr
  reg Addu, Subu, Sub, Add, And, Or, Xor, Nor, Sll, Sllv, Slt, Sltu, Sra, Srav, Srl, Srlv;
  // jump1 jump2
  reg Jr, Jalr, Jal, J;
  // cali
  reg Lui, Ori, Addi, Addiu, Andi, Xori, Slti, Sltiu;
  // branch
  reg Beq, Bne, Bgtz, Blez, Bgez, Bltz;
  //readhl
  reg Mfhi, Mflo;
  //writehl
  reg Mthi, Mtlo;
  //calmudi
  reg Mult, Multu, Div, Divu;
  //load
  reg Lw, Lb, Lbu, Lh, Lhu;
  //store
  reg Sw, Sb, Sh;
  //nop
  reg Nop;

  // identify instr
  always @(*) begin
    Addu  = 0;
    Subu  = 0;
    Sub   = 0;
    Add   = 0;
    And   = 0;
    Or    = 0;
    Xor   = 0;
    Nor   = 0;
    Sll   = 0;
    Sllv  = 0;
    Slt   = 0;
    Sltu  = 0;
    Sra   = 0;
    Srav  = 0;
    Srl   = 0;
    Srlv  = 0;
    Beq   = 0;
    Bne   = 0;
    Bgtz  = 0;
    Blez  = 0;
    Bgez  = 0;
    Bltz  = 0;
    Jr    = 0;
    Jalr  = 0;
    Jal   = 0;
    J     = 0;
    Sw    = 0;
    Sb    = 0;
    Sh    = 0;
    Lw    = 0;
    Lb    = 0;
    Lbu   = 0;
    Lh    = 0;
    Lhu   = 0;
    Mfhi  = 0;
    Mflo  = 0;
    Mthi  = 0;
    Mtlo  = 0;
    Mult  = 0;
    Multu = 0;
    Div   = 0;
    Divu  = 0;
    Lui   = 0;
    Ori   = 0;
    Addi  = 0;
    Addiu = 0;
    Andi  = 0;
    Xori  = 0;
    Slti  = 0;
    Sltiu = 0;
    Nop   = 0;
    case (op)
      // all R-types
      `R: begin
        case (fn)
          `Addu: Addu = 1;
          `Subu: Subu = 1;
          `Sub: Sub = 1;
          `Add: Add = 1;
          `And: And = 1;
          `Or: Or = 1;
          `Xor: Xor = 1;
          `Nor: Nor = 1;
          6'b000000: begin
            if (nInstr != 32'b0) Sll = 1;
            else Nop = 1;
          end
          `Sllv: Sllv = 1;
          `Slt: Slt = 1;
          `Sltu: Sltu = 1;
          `Sra: Sra = 1;
          `Srav: Srav = 1;
          `Srl: Srl = 1;
          `Srlv: Srlv = 1;
          `Jr: Jr = 1;
          `Jalr: Jalr = 1;
          `Mfhi: Mfhi = 1;
          `Mflo: Mflo = 1;
          `Mthi: Mthi = 1;
          `Mtlo: Mtlo = 1;
          `Mult: Mult = 1;
          `Multu: Multu = 1;
          `Div: Div = 1;
          `Divu: Divu = 1;
          default: Nop = 1;
        endcase
      end
      // I-type branch
      `Beq: Beq = 1;
      `Bne: Bne = 1;
      `Bgtz: Bgtz = 1;
      `Blez: Blez = 1;
      `BgezOrBltz: begin
        if (nInstr_20_16 == 5'b0) Bltz = 1;
        else if (nInstr_20_16 == 5'b1) Bgez = 1;
      end
      // I-type cali
      `Lui: Lui = 1;
      `Ori: Ori = 1;
      `Addi: Addi = 1;
      `Addiu: Addiu = 1;
      `Andi: Andi = 1;
      `Xori: Xori = 1;
      `Slti: Slti = 1;
      `Sltiu: Sltiu = 1;
      // I-type load
      `Lw: Lw = 1;
      `Lb: Lb = 1;
      `Lbu: Lbu = 1;
      `Lh: Lh = 1;
      `Lhu: Lhu = 1;
      // I-type store
      `Sw: Sw = 1;
      `Sb: Sb = 1;
      `Sh: Sh = 1;
      // J-type jump2
      `J: J = 1;
      `Jal: Jal = 1;
      default: Nop = 1;
    endcase
  end

  //category all instrs
  wire cali, calr, calmudi, store, load, branch, jump1, jump2, writehl, readhl;
  assign cali = Lui | Ori | Addi | Addiu | Andi | Xori | Slti | Sltiu;
  assign calr = Add | Addu | Sub | Subu | And | Or | Xor | Nor | Sll | Sllv | Sra | Srav | Srl | Srlv | Slt | Sltu;
  assign calmudi = Mult | Multu | Div | Divu;
  assign readhl = Mflo | Mfhi;
  assign writehl = Mthi | Mtlo;
  assign jump1 = Jalr | Jr;
  assign jump2 = J | Jal;
  assign branch = Beq | Bgtz | Blez | Bgez | Bltz | Bne;
  assign load = Lw | Lb | Lbu | Lh | Lhu;
  assign store = Sw | Sb | Sh;

  // assign all control signals
  assign regDst = (calr | Jalr | readhl) ? 2'b01 : (Jal) ? 2'b10 : 2'b00;
  assign regWrite = calr | cali | readhl | Jal | Jalr | load;
  assign memWrite = store;
  assign aluSrc = cali | store | load;
  assign memRead = load;
  assign extOp = (Xori | Andi | Ori) ? 2'b00 : 2'b01;
  assign memToR = (load) ? 3'b001 : (Jal | Jalr) ? 3'b010 : (Mfhi | Mflo) ? 3'b011 : 3'b000;

  assign branchType = Beq ? 3'b001 : Bgtz ? 3'b010 : Blez ? 3'b011 : Bgez ? 3'b100 : Bltz ? 3'b101 : Bne ? 3'b110 : 3'b000;
  assign jumpOp = branch ? 3'b001 : jump2 ? 3'b010 : jump1 ? 3'b011 : 3'b000;
  assign aluOp =  (Addu||Add||Addi||Addiu||load||store)?4'b0000:
    (Subu|Sub)?4'b0001:
    (And|Andi)?4'b0010:
						 (Ori|Or)?4'b0011:
						 (Xor|Xori)?4'b0100:
              (Nor)?4'b0101:
						 (Sll|Sllv)?4'b0110:
						 (Srl|Srlv)?4'b0111:
						 (Sra|Srav)?4'b1000:
             (Sltu|Sltiu)?4'b1001:
						 (Slt|Slti)?4'b1010:
						 (Lui)?4'b1011:
						 4'b0000;
  assign isShamt = Srl | Sra | Sll;
  assign loadOp = Lbu ? 3'b001 : Lb ? 3'b010 : Lhu ? 3'b011 : Lh ? 3'b100 : 3'b000;
  assign storeOp = Sh ? 2'b01 : Sb ? 2'b10 : 2'b00;
  assign start = calmudi;
  assign mudiOp = Mult ? 3'b000 : Multu ? 3'b001 : Div ? 3'b010 : Divu ? 3'b011 : 3'b000;
  assign hiRead = Mfhi;
  assign loRead = Mflo;
  assign hiWrite = Mthi;
  assign loWrite = Mtlo;
endmodule
