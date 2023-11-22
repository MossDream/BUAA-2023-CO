`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:47:04 11/12/2023 
// Design Name: 
// Module Name:    MUDI_Processor 
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
module MUDI_Processor (
    input              clk,
    input              reset,
    input       [31:0] A,
    input       [31:0] B,
    input              start,
    input       [ 2:0] mudiOp,
    input              hiWrite,
    input              loWrite,
    input              hiRead,
    input              loRead,
    output reg  [31:0] HI,
    output reg  [31:0] LO,
    output wire        busy,
    output wire [31:0] mudiRD
);
  reg [31:0] hi;
  reg [31:0] lo;
  reg [ 3:0] cnt;
  initial begin
    HI  = 0;
    LO  = 0;
    hi  = 0;
    lo  = 0;
    cnt = 0;
  end
  always @(posedge clk) begin
    if (reset) begin
      HI  = 0;
      LO  = 0;
      hi  = 0;
      lo  = 0;
      cnt = 0;
    end else if (start) begin
      // start
      case (mudiOp)
        3'd0: begin
          // mult
          {hi, lo} <= $signed(A) * $signed(B);
          // simulate 5 cycles
          cnt      <= 5;
        end
        3'd1: begin
          // multu
          {hi, lo} <= A * B;
          cnt      <= 5;
        end
        3'd2: begin
          // div
          lo  <= $signed(A) / $signed(B);
          hi  <= $signed(A) % $signed(B);
          // simulate 10 cycles
          cnt <= 10;
        end
        3'd3: begin
          // divu
          lo  <= A / B;
          hi  <= A % B;
          cnt <= 10;
        end
      endcase
    end else if (hiWrite) begin
      HI <= A;
    end else if (loWrite) begin
      LO <= A;
    end else if (cnt != 0) begin
      // simulate for 5 or 10 cycles
      if (cnt == 4'd1) begin
        LO <= lo;
        HI <= hi;
      end
      cnt <= cnt - 1;
    end
  end
  assign busy   = (start || (cnt) != 0) ? 1 : 0;
  assign mudiRD = (hiRead) ? HI : (loRead) ? LO : 0;
endmodule
