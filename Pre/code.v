`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:43:24 08/15/2023 
// Design Name: 
// Module Name:    code 
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
module code (
    input             Clk,
    input             Reset,
    input             Slt,
    input             En,
    output reg [63:0] Output0,
    output reg [63:0] Output1
);
  initial begin
    Output0 <= 64'h0000000000000000;
    Output1 <= 64'h0000000000000000;
  end
  reg [1:0] tick = 2'b1;
  always @(posedge Clk) begin
    if (Reset) begin
      Output0 <= 64'h0000000000000000;
      Output1 <= 64'h0000000000000000;
      tick    <= 1;
    end else if (En) begin
      if (Slt) begin
        tick <= tick + 1;
        if (tick == 2'b0) begin
          Output1 <= Output1 + 1;
        end else begin
          Output1 = Output1;
        end
      end else begin
        Output0 = Output0 + 1;
      end
    end
  end


endmodule
