`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:34:40 10/31/2023 
// Design Name: 
// Module Name:    DM 
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
module DM (
    input         clk,
    input         reset,
    input         WE,
    input         RE,
    input  [31:0] A,
    input  [31:0] pc,
    input  [31:0] WD,
    output [31:0] RD
);
  reg     [31:0] ram   [0:3071];
  // real address
  wire    [11:0] addr;
  integer        i = 0;
  assign addr = A[13:2];
  always @(posedge clk) begin
    if (reset == 1'b1) begin
      for (i = 0; i < 3072; i = i + 1) begin
        ram[i] <= 32'd0;
      end
    end else begin
      if (WE == 1'b1) begin
        ram[addr] <= WD;
        // display for test
        $display("%d@%h: *%h <= %h", $time, pc, A, WD);
      end else begin
        ram[addr] <= ram[addr];
      end
    end
  end
  assign RD = (RE == 1'b1) ? ram[addr] : 32'b0;
endmodule
