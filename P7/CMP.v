`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:19:15 11/04/2023 
// Design Name: 
// Module Name:    CMP 
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
module CMP (
    input      [31:0] A,
    input      [31:0] B,
    input      [ 2:0] branchType,
    output reg        branchEn
);
  always @(*) begin
    case (branchType)
      3'd0: begin
        //none
        branchEn = 0;
      end
      3'd1: begin
        //beq
        if (A == B) begin
          branchEn = 1;
        end else begin
          branchEn = 0;
        end
      end
      3'd2: begin
        //bgtz
        if ($signed(A) > 0) begin
          branchEn = 1;
        end else begin
          branchEn = 0;
        end
      end
      3'd3: begin
        //blez
        if ($signed(A) <= 0) begin
          branchEn = 1;
        end else begin
          branchEn = 0;
        end
      end
      3'd4: begin
        //bgez
        if ($signed(A) >= 0) begin
          branchEn = 1;
        end else begin
          branchEn = 0;
        end
      end
      3'd5: begin
        //bltz
        if ($signed(A) < 0) begin
          branchEn = 1;
        end else begin
          branchEn = 0;
        end
      end
      3'd6: begin
        //bne
        if (A == B) begin
          branchEn = 0;
        end else begin
          branchEn = 1;
        end
      end
      default: branchEn = 0;
    endcase
  end
endmodule
