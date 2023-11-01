`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:45:45 10/31/2023 
// Design Name: 
// Module Name:    All_MUXs 
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
    input      [31:0] R,
    input      [31:0] RD,
    input      [15:0] imm_16,
    input      [31:0] pc,
    input      [ 1:0] memToR,
    output reg [31:0] WD
);
  always @(*) begin
    case (memToR)
      2'b00: begin
        WD = R;
      end
      2'b01: begin
        WD = RD;
      end
      2'b10: begin
        WD = {imm_16, {16{1'b0}}};
      end
      2'b11: begin
        WD = pc + 32'd4;
      end
      default: begin
        WD = 0;
      end
    endcase
  end
endmodule
