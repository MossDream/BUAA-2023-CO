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
    input      [31:0] extImm,
    input      [31:0] W_pcPlus8,
    input      [ 1:0] memToR,
    output reg [31:0] WD
);
  always @(*) begin
    case (memToR)
      2'b00: begin
        WD = aluRes;
      end
      2'b01: begin
        WD = dmData;
      end
      2'b10: begin
        WD = extImm;
      end
      2'b11: begin
        WD = W_pcPlus8;
      end
      default: begin
        WD = 0;
      end
    endcase
  end
endmodule

module isLui_sel (
    input         isLui,
    input  [31:0] E_extImm,
    input  [31:0] E_aluRes,
    output [31:0] realAluRes
);
  assign realAluRes = (isLui) ? E_extImm : E_aluRes;
endmodule
