`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:36:27 10/31/2023 
// Design Name: 
// Module Name:    mips 
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
module mips (
    input clk,
    input reset
);
  wire [31:0] nInstr;
  wire [ 5:0] op;
  wire [ 5:0] fn;
  wire [15:0] offset;
  wire [25:0] instr_index;
  wire [ 4:0] rs;
  wire [ 4:0] rt;
  wire [ 4:0] rd;
  wire [31:0] pc;
  wire        zero;
  wire [31:0] RD1;
  wire [31:0] RD2;
  wire [ 2:0] jumpOp;
  wire        regWrite;
  wire        memRead;
  wire        memWrite;
  wire        extOp;
  wire [ 2:0] aluOp;
  wire [ 1:0] regDst;
  wire [ 1:0] memToR;
  wire        aluSrc;
  wire [ 4:0] A3;
  wire [31:0] WD;
  wire [31:0] B;
  wire [31:0] dataOut;
  wire [31:0] R;
  wire [31:0] RD;

  //datapath-Splliter 
  assign op          = nInstr[31:26];
  assign fn          = nInstr[5:0];
  assign offset      = nInstr[15:0];
  assign instr_index = nInstr[25:0];
  assign rs          = nInstr[25:21];
  assign rt          = nInstr[20:16];
  assign rd          = nInstr[15:11];


  //datapath-IFU
  IFU mips_IFU (
      .clk        (clk),
      .reset      (reset),
      .zero       (zero),
      .offset     (offset),
      .instr_index(instr_index),
      .rsIn       (RD1),
      .jumpOp     (jumpOp),
      //output
      .nInstr     (nInstr),
      .pc         (pc)
  );

  //datapath-GRF
  GRF mips_GRF (
      .clk  (clk),
      .reset(reset),
      .WE   (regWrite),
      .A1   (rs),
      .A2   (rt),
      .A3   (A3),
      .WD   (WD),
      .pc   (pc),
      //output
      .RD1  (RD1),
      .RD2  (RD2)
  );

  //datapath-EXT
  EXT mips_EXT (
      .dataIn (offset),
      .extOp  (extOp),
      //output
      .dataOut(dataOut)
  );

  //datapath-ALU
  ALU mips_ALU (
      .A    (RD1),
      .B    (B),
      .aluOp(aluOp),
      //output
      .R    (R),
      .zero (zero)
  );

  //datapath-DM
  DM mips_DM (
      .clk  (clk),
      .reset(reset),
      .WE   (memWrite),
      .RE   (memRead),
      .A    (R),
      .pc   (pc),
      .WD   (RD2),
      //output
      .RD   (RD)
  );

  //datapath-regDst_sel
  regDst_sel mips_regDst_sel (
      .rt    (rt),
      .rd    (rd),
      .regDst(regDst),
      //output
      .A3    (A3)
  );

  //datapath-aluSrc_sel
  aluSrc_sel mips_aluSrc_sel (
      .RD2    (RD2),
      .dataOut(dataOut),
      .aluSrc (aluSrc),
      //output
      .B      (B)
  );

  //datapath-memToR_sel
  memToR_sel mips_memToR_sel (
      .R     (R),
      .RD    (RD),
      .imm_16(offset),
      .pc    (pc),
      .memToR(memToR),
      //output
      .WD    (WD)
  );

  //control
  Controller mips_Controller (
      .op      (op),
      .fn      (fn),
      //output
      .regDst  (regDst),
      .aluSrc  (aluSrc),
      .aluOp   (aluOp),
      .memToR  (memToR),
      .memWrite(memWrite),
      .memRead (memRead),
      .regWrite(regWrite),
      .extOp   (extOp),
      .jumpOp  (jumpOp)
  );
endmodule
