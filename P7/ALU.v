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
    input      [ 3:0] aluOp,
    input      [ 4:0] shamt,
    output reg [31:0] R,
    output            overflow
);
  reg temp;
  always @(*) begin
    temp = 0;
    case (aluOp)
      4'd0: {temp, R} = {A[31], A} + {B[31], B};
      4'd1: {temp, R} = {A[31], A} - {B[31], B};
      4'd2: R = A & B;
      4'd3: R = A | B;
      4'd4: R = A ^ B;
      4'd5: R = ~(A | B);
      4'd6: R = B << shamt;
      4'd7: R = B >> shamt;
      4'd8: R = ($signed(B)) >>> shamt;
      4'd9: R = (A < B) ? 32'd1 : 32'd0;  // sltu sltiu
      4'd10: R = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;  // slt slti
      4'd11: R = {B[15:0], {16{1'b0}}};  // lui
      default: R = R;
    endcase
  end
  assign overflow = (temp != R[31]) && (aluOp == 4'd0 || aluOp == 4'd1);
endmodule
