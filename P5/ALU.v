`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:17:54 10/31/2023 
// Design Name: 
// Module Name:    ALU 
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
module ALU (
    input      [31:0] A,
    input      [31:0] B,
    input      [ 2:0] aluOp,
    output reg [31:0] R,
    output            zero
);
  always @(*) begin
    case (aluOp)
      3'd0: R = A + B;
      3'd1: R = A - B;
      3'd2: R = A & B;
      3'd3: R = A | B;
      3'd4: R = R;
      default: R = R;
    endcase
  end
  assign zero = (A == B) ? 1 : 0;
endmodule
