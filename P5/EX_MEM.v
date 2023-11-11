`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:09:03 11/05/2023 
// Design Name: 
// Module Name:    EX_MEM 
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
module EX_MEM (
    input             clk,
    input             reset,
    input             enable,
    input      [31:0] E_nInstr,
    input      [31:0] E_pc,
    input      [31:0] E_pcPlus4,
    input      [31:0] E_pcPlus8,
    input      [31:0] E_rtData,
    input      [31:0] E_aluRes,
    input      [31:0] E_extImm,
    output reg [31:0] nInstr_M,
    output reg [31:0] pc_M,
    output reg [31:0] pcPlus4_M,
    output reg [31:0] pcPlus8_M,
    output reg [31:0] rtData_M,
    output reg [31:0] aluRes_M,
    output reg [31:0] extImm_M
);
  always @(posedge clk) begin
    if (reset) begin
      nInstr_M  <= 0;
      pc_M      <= 32'h00003000;
      pcPlus4_M <= 32'h00003004;
      pcPlus8_M <= 32'h00003008;
      rtData_M  <= 0;
      aluRes_M  <= 0;
      extImm_M  <= 0;
    end else if (enable) begin
      nInstr_M  <= E_nInstr;
      pc_M      <= E_pc;
      pcPlus4_M <= E_pcPlus4;
      pcPlus8_M <= E_pcPlus8;
      rtData_M  <= E_rtData;
      aluRes_M  <= E_aluRes;
      extImm_M  <= E_extImm;
    end
  end
endmodule
