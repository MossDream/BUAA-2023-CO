`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:24:04 11/06/2023 
// Design Name: 
// Module Name:    Haz_Decoder 
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
module Haz_Decoder (
    input      [31:0] nInstr,
    output            cali,
    output            calr,
    output            calmudi,
    output            store,
    output            load,
    output            branch,
    output            writehl,
    output            readhl,
    // additional
    output            allmudi,
    output reg        Jr,
    output reg        Jalr,
    output reg        Jal,
    output reg        Mtc0,
    output reg        Mfc0,
    output reg        Eret
);
  // for identify Bgez and Bltz
  wire nInstr_20_16;
  assign nInstr_20_16 = nInstr[20:16];

  // all instrs
  // calr
  reg Addu, Subu, Sub, Add, And, Or, Xor, Nor, Sll, Sllv, Slt, Sltu, Sra, Srav, Srl, Srlv;
  // jump1 jump2
  reg J;
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
    Mtc0  = 0;
    Mfc0  = 0;
    Eret  = 0;
    case (nInstr[`op])
      // all R-types
      `R: begin
        case (nInstr[`fn])
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
      // Exception
      `COP0: begin
        if (nInstr == `full_eret) Eret = 1;
        else if (nInstr[`rs] == `mfc0_rs) begin
          Mfc0 = 1;
        end else if (nInstr[`rs] == `mtc0_rs) begin
          Mtc0 = 1;
        end
      end
      default: Nop = 1;
    endcase
  end

  //category all instrs
  assign cali    = Lui | Ori | Addi | Addiu | Andi | Xori | Slti | Sltiu;
  assign calr    = Add | Addu | Sub | Subu | And | Or | Xor | Nor | Sll | Sllv | Sra | Srav | Srl | Srlv | Slt | Sltu;
  assign calmudi = Mult | Multu | Div | Divu;
  assign readhl  = Mflo | Mfhi;
  assign writehl = Mthi | Mtlo;
  assign branch  = Beq | Bgtz | Blez | Bgez | Bltz | Bne;
  assign load    = Lw | Lb | Lbu | Lh | Lhu;
  assign store   = Sw | Sb | Sh;
  assign allmudi = calmudi | readhl | writehl;

endmodule
