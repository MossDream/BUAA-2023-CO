`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:15:31 11/05/2023 
// Design Name: 
// Module Name:    MEM_WB 
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
module MEM_WB (
    input             clk,
    input             reset,
    input             enable,
    input      [31:0] M_nInstr,
    input      [31:0] M_pc,
    input      [31:0] M_pcPlus4,
    input      [31:0] M_pcPlus8,
    input      [31:0] M_rtData,
    input      [31:0] M_aluRes,
    input      [31:0] M_extImm,
    input      [31:0] M_dmData,
    output reg [31:0] nInstr_W,
    output reg [31:0] pc_W,
    output reg [31:0] pcPlus4_W,
    output reg [31:0] pcPlus8_W,
    output reg [31:0] rtData_W,
    output reg [31:0] aluRes_W,
    output reg [31:0] extImm_W,
    output reg [31:0] dmData_W
);
  always @(posedge clk) begin
    if (reset) begin
      nInstr_W  <= 0;
      pc_W      <= 0;
      pcPlus4_W <= 0;
      pcPlus8_W <= 0;
      rtData_W  <= 0;
      aluRes_W  <= 0;
      extImm_W  <= 0;
      dmData_W  <= 0;
    end else if (enable) begin
      nInstr_W  <= M_nInstr;
      pc_W      <= M_pc;
      pcPlus4_W <= M_pcPlus4;
      pcPlus8_W <= M_pcPlus8;
      rtData_W  <= M_rtData;
      aluRes_W  <= M_aluRes;
      extImm_W  <= M_extImm;
      dmData_W  <= M_dmData;
    end
  end
endmodule
