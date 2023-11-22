`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:47:12 11/04/2023 
// Design Name: 
// Module Name:    ID_EX 
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
module ID_EX (
    input             clk,
    input             reset,
    input             enable,
    input      [31:0] D_nInstr,
    input      [31:0] D_pc,
    input      [31:0] D_pcPlus4,
    input      [31:0] D_pcPlus8,
    input      [31:0] D_RD1,
    input      [31:0] D_RD2,
    input      [31:0] D_dataOut,
    input             D_BDIn,
    input      [ 4:0] D_excCode,
    output reg [31:0] nInstr_E,
    output reg [31:0] pc_E,
    output reg [31:0] pcPlus4_E,
    output reg [31:0] pcPlus8_E,
    output reg [31:0] rsData_E,
    output reg [31:0] rtData_E,
    output reg [31:0] extImm_E,
    output reg        BDIn_E,
    output reg [ 4:0] excCode_E
);

  always @(posedge clk) begin
    if (reset) begin
      nInstr_E  <= 0;
      pc_E      <= 32'h00003000;
      pcPlus4_E <= 32'h00003004;
      pcPlus8_E <= 32'h00003008;
      rsData_E  <= 0;
      rtData_E  <= 0;
      extImm_E  <= 0;
      BDIn_E    <= 0;
      excCode_E <= 5'd0;
    end else if (enable) begin
      nInstr_E  <= D_nInstr;
      pc_E      <= D_pc;
      pcPlus4_E <= D_pcPlus4;
      pcPlus8_E <= D_pcPlus8;
      rsData_E  <= D_RD1;
      rtData_E  <= D_RD2;
      extImm_E  <= D_dataOut;
      BDIn_E    <= D_BDIn;
      excCode_E <= D_excCode;
    end
  end
endmodule
