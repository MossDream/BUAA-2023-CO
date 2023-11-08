`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:12:31 11/04/2023 
// Design Name: 
// Module Name:    IF-ID 
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
module IF_ID (
    input             clk,
    input             reset,
    input             enable,
    input      [31:0] F_pc,
    input      [31:0] F_nInstr,
    output reg [31:0] pc_D,
    output reg [31:0] pcPlus4_D,
    output reg [31:0] pcPlus8_D,
    output reg [31:0] nInstr_D
);
  always @(posedge clk) begin
    if (reset == 1) begin
      pc_D      <= 32'h00003000;
      pcPlus4_D <= 32'h00003004;
      pcPlus8_D <= 32'h00003008;
      nInstr_D  <= 32'h00000000;
    end else if (enable) begin
      pc_D      <= F_pc;
      pcPlus4_D <= F_pc + 4;
      pcPlus8_D <= F_pc + 8;
      nInstr_D  <= F_nInstr;
    end
  end
endmodule
