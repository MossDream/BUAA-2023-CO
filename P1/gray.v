`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:16:06 10/10/2023 
// Design Name: 
// Module Name:    gray 
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
module gray (
    input            Clk,
    input            Reset,
    input            En,
    output reg [2:0] Output,
    output reg       Overflow
);
  initial begin
    Output   = 3'b000;
    Overflow = 1'b0;
  end
  always @(posedge Clk) begin
    if (Reset == 1'b1) begin
      Output   <= 3'b000;
      Overflow <= 1'b0;
    end else begin
      if (En == 1'b1) begin
        case (Output)
          3'd0: Output <= 3'b001;
          3'd1: Output <= 3'b011;
          3'd3: Output <= 3'b010;
          3'd2: Output <= 3'b110;
          3'd6: Output <= 3'b111;
          3'd7: Output <= 3'b101;
          3'd5: Output <= 3'b100;
          3'd4: begin
            Output   <= 3'b000;
            Overflow <= 1'b1;
          end
        endcase
      end
    end
  end
endmodule
