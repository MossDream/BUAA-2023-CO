`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:09:15 10/31/2023 
// Design Name: 
// Module Name:    EXT 
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
module EXT (
    input      [15:0] dataIn,
    input      [ 1:0] extOp,
    output reg [31:0] dataOut
);
  always @(*) begin
    if (extOp == 2'b00) begin
      dataOut = {{16{1'b0}}, dataIn};
    end else if (extOp == 2'b01) begin
      dataOut = {{16{dataIn[15]}}, dataIn};
    end else if (extOp == 2'b10) begin
      dataOut = {dataIn, {16{1'b0}}};
    end else begin
      dataOut = 0;
    end
  end
endmodule
