`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:39:57 10/31/2023 
// Design Name: 
// Module Name:    GRF 
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
module GRF (
    input         clk,
    input         reset,
    input         WE,
    input  [ 4:0] A1,
    input  [ 4:0] A2,
    input  [ 4:0] A3,
    input  [31:0] WD,
    input  [31:0] pc,
    output [31:0] RD1,
    output [31:0] RD2
);
  reg     [31:0] regfile[0:31];
  integer        i = 0;
  always @(posedge clk) begin
    if (reset == 1'b1) begin
      for (i = 0; i < 32; i = i + 1) begin
        regfile[i] <= 32'd0;
      end
    end else begin
      if (WE == 1'b1) begin
        if (A3 != 5'd0) begin
          regfile[A3] <= WD;
          //display for test
          $display("@%h: $%d <= %h", pc, A3, WD);
        end else begin
          regfile[0] <= 32'd0;
        end
      end
    end
  end
  assign RD1 = regfile[A1];
  assign RD2 = regfile[A2];
endmodule
