`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:58:42 10/31/2023 
// Design Name: 
// Module Name:    Controller 
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
module Controller (
    input      [5:0] op,
    input      [5:0] fn,
    output reg [1:0] regDst,
    output reg       aluSrc,
    output reg [2:0] aluOp,
    output reg [1:0] memToR,
    output reg       memWrite,
    output reg       memRead,
    output reg       regWrite,
    output reg       extOp,
    output reg [2:0] jumpOp
);
  always @(*) begin
    case (op)
      6'b000000: begin
        //R-type
        regDst   = 2'b01;
        aluSrc   = 0;
        memRead  = 0;
        memWrite = 0;
        extOp    = extOp;
        case (fn)
          6'b100000: begin
            //add
            aluOp    = 3'b000;
            memToR   = 2'b00;
            regWrite = 1;
            jumpOp   = 3'b000;
          end
          6'b100010: begin
            //sub
            aluOp    = 3'b001;
            memToR   = 2'b00;
            regWrite = 1;
            jumpOp   = 3'b000;
          end
          6'b001000: begin
            //jr
            aluOp    = aluOp;
            memToR   = memToR;
            regWrite = 0;
            jumpOp   = 3'b011;
          end
          default: begin
            regDst   = 0;
            aluSrc   = 0;
            aluOp    = 0;
            memToR   = 0;
            memWrite = 0;
            memRead  = 0;
            regWrite = 0;
            extOp    = 0;
            jumpOp   = 0;
          end
        endcase
      end
      6'b100011: begin
        //lw
        regDst   = 2'b00;
        aluSrc   = 1;
        aluOp    = 3'b000;
        memToR   = 2'b01;
        memWrite = 0;
        memRead  = 1;
        regWrite = 1;
        extOp    = 1;
        jumpOp   = 3'b000;
      end
      6'b101011: begin
        //sw
        regDst   = regDst;
        aluSrc   = 1;
        aluOp    = 3'b000;
        memToR   = memToR;
        memWrite = 1;
        memRead  = 0;
        regWrite = 0;
        extOp    = 1;
        jumpOp   = 3'b000;
      end
      6'b000100: begin
        //beq
        regDst   = regDst;
        aluSrc   = 0;
        aluOp    = 3'b100;
        memToR   = memToR;
        memWrite = 0;
        memRead  = 0;
        regWrite = 0;
        extOp    = extOp;
        jumpOp   = 3'b001;
      end
      6'b001101: begin
        //ori
        regDst   = 2'b00;
        aluSrc   = 1;
        aluOp    = 3'b011;
        memToR   = 2'b00;
        memWrite = 0;
        memRead  = 0;
        regWrite = 1;
        extOp    = 0;
        jumpOp   = 3'b000;
      end
      6'b001111: begin
        //lui
        regDst   = 2'b00;
        aluSrc   = aluSrc;
        aluOp    = aluOp;
        memToR   = 2'b10;
        memWrite = 0;
        memRead  = 0;
        regWrite = 1;
        extOp    = extOp;
        jumpOp   = 3'b000;
      end
      6'b000011: begin
        //jal
        regDst   = 2'b10;
        aluSrc   = aluSrc;
        aluOp    = aluOp;
        memToR   = 2'b11;
        memWrite = 0;
        memRead  = 0;
        regWrite = 1;
        extOp    = extOp;
        jumpOp   = 3'b010;
      end
      default: begin
        regDst   = 0;
        aluSrc   = 0;
        aluOp    = 0;
        memToR   = 0;
        memWrite = 0;
        memRead  = 0;
        regWrite = 0;
        extOp    = 0;
        jumpOp   = 0;
      end
    endcase
  end
endmodule
