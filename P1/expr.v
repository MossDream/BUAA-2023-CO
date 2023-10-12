`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:21:14 10/10/2023 
// Design Name: 
// Module Name:    expr 
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
`define S0 2'd0 //空串
`define S1 2'd1 //合法
`define S2 2'd2 //多位当前不合法，但之后可能合法
`define S3 2'd3 //多位当前不合法，之后也不可能合法 
module expr (
    input            clk,
    input            clr,
    input      [7:0] in,
    output reg       out
);
  reg [1:0] state = 0;
  reg [1:0] next = 0;
  always @(posedge clk or posedge clr) begin
    if (clr == 1'b1) begin
      state <= `S0;
    end else begin
      state <= next;
    end
  end

  always @(state, in) begin
    case (state)
      `S0: begin
        if (in >= "0" && in <= "9") begin
          next = `S1;
        end else begin
          next = `S3;
        end
        out = 1'b0;
      end
      `S1: begin
        if (in == "+" || in == "*") begin
          next = `S2;
        end else begin
          next = `S3;
        end
        out = 1'b1;
      end
      `S2: begin
        if (in >= "0" && in <= "9") begin
          next = `S1;
        end else begin
          next = `S3;
        end
        out = 1'b0;
      end
      `S3: begin
        next = `S3;
        out  = 1'b0;
      end
      default: begin
        next = `S0;
        out  = 1'b0;
      end
    endcase
  end


endmodule
