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
    input      [31:0] E_hiloData,
    input             E_BDIn,
    input             E_overflow,
    input      [ 4:0] E_excCode,
    output reg [31:0] nInstr_M,
    output reg [31:0] pc_M,
    output reg [31:0] pcPlus4_M,
    output reg [31:0] pcPlus8_M,
    output reg [31:0] rtData_M,
    output reg [31:0] aluRes_M,
    output reg [31:0] extImm_M,
    output reg [31:0] hiloData_M,
    output reg        BDIn_M,
    output reg        overflow_M,
    output reg [ 4:0] excCode_M
);
  always @(posedge clk) begin
    if (reset) begin
      nInstr_M   <= 0;
      pc_M       <= 32'h00003000;
      pcPlus4_M  <= 32'h00003004;
      pcPlus8_M  <= 32'h00003008;
      rtData_M   <= 0;
      aluRes_M   <= 0;
      extImm_M   <= 0;
      hiloData_M <= 0;
      BDIn_M     <= 0;
      overflow_M <= 0;
      excCode_M  <= 5'd0;
    end else if (enable) begin
      nInstr_M   <= E_nInstr;
      pc_M       <= E_pc;
      pcPlus4_M  <= E_pcPlus4;
      pcPlus8_M  <= E_pcPlus8;
      rtData_M   <= E_rtData;
      aluRes_M   <= E_aluRes;
      extImm_M   <= E_extImm;
      hiloData_M <= E_hiloData;
      BDIn_M     <= E_BDIn;
      overflow_M <= E_overflow;
      excCode_M  <= E_excCode;
    end
  end
endmodule
