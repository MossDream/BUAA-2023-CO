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
    input  [31:0] nInstr,
    output        isCali,
    output        isCalr,
    output        isJal,
    output        isJr,
    output        isLoad,
    output        isStore,
    output        isBeq
);
  assign isCali  = (nInstr[`op] == `lui || nInstr[`op] == `ori);
  assign isCalr  = (nInstr[`op] == `R && nInstr[`fn] != `jr);
  assign isJal   = (nInstr[`op] == `jal);
  assign isJr    = (nInstr[`op] == `R && nInstr[`fn] == `jr);
  assign isLoad  = (nInstr[`op] == `lw);
  assign isStore = (nInstr[`op] == `sw);
  assign isBeq   = (nInstr[`op] == `beq);
endmodule
