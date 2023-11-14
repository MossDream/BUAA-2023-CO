`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:06:45 11/05/2023 
// Design Name: 
// Module Name:    
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
module regDst_sel (
    input      [4:0] rt,
    input      [4:0] rd,
    input      [1:0] regDst,
    output reg [4:0] A3
);
  always @(*) begin
    case (regDst)
      2'b00: begin
        A3 = rt;
      end
      2'b01: begin
        A3 = rd;
      end
      2'b10: begin
        A3 = 5'd31;
      end
      default: begin
        A3 = A3;
      end
    endcase
  end
endmodule

module aluSrc_sel (
    input  [31:0] RD2,
    input  [31:0] dataOut,
    input         aluSrc,
    output [31:0] B
);
  assign B = (aluSrc) ? dataOut : RD2;
endmodule

module memToR_sel (
    input      [31:0] aluRes,
    input      [31:0] dmData,
    input      [31:0] W_pcPlus8,
    input      [31:0] W_hiloData,
    input      [ 2:0] memToR,
    output reg [31:0] WD
);
  always @(*) begin
    case (memToR)
      3'b000: begin
        WD = aluRes;
      end
      3'b001: begin
        WD = dmData;
      end
      3'b010: begin
        WD = W_pcPlus8;
      end
      3'b011: begin
        WD = W_hiloData;
      end
      default: begin
        WD = 0;
      end
    endcase
  end
endmodule

module isShamt_sel (
    input  [4:0] shamt,
    input  [4:0] rs_4_0,
    input        isShamt,
    output [4:0] shamtData
);
  assign shamtData = (isShamt == 1) ? shamt : rs_4_0;

endmodule
