`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:24:08 08/15/2023 
// Design Name: 
// Module Name:    id_fsm 
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
`define S0 2'b00 
`define S1 2'b01
`define S2 2'b10
module id_fsm (
    input  [7:0] char,
    input        clk,
    output       out
);
  reg [1:0] status;
  wire isDigit, isAlpha;
  assign isDigit = (char >= 8'd48 && char <= 8'd57) ? 2'b1 : 2'b0;
  assign isAlpha = ((char >= 8'd65 && char <= 8'd90) || (char >= 8'd97 && char <= 8'd122)) ? 2'b1 : 2'b0;

  initial begin
    status <= `S0;
  end

  always @(posedge clk) begin
    case (status)
      `S0: begin
        if (isDigit) begin
          status <= `S0;
        end else if (isAlpha) begin
          status <= `S1;
        end else begin
          status <= `S0;  //对于一切非正常输入，回到状态0
        end
      end

      `S1: begin
        if (isDigit) begin
          status <= `S2;
        end else if (isAlpha) begin
          status <= `S1;
        end else begin
          status <= `S0;  //对于一切非正常输入，回到状态0
        end
      end

      `S2: begin
        if (isDigit) begin
          status <= `S2;
        end else if (isAlpha) begin
          status <= `S1;
        end else begin
          status <= `S0;  //对于一切非正常输入，回到状态0
        end
      end
    endcase
  end
  assign out = (status == `S2) ? 1'b1 : 1'b0;


endmodule
