`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:33:00 11/03/2023 
// Design Name: 
// Module Name:    IFU 
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
module IFU (
    input             clk,
    input             reset,
    input             enable,
    input             branchEn,
    input      [15:0] offset,
    input      [25:0] instr_index,
    input      [31:0] rsIn,
    input      [31:0] D_pcPlus4,
    input      [ 2:0] jumpOp,
    //output reg [31:0] nInstr,
    output reg [31:0] pc
);
  initial begin
    pc = 32'h00003000;
  end
  reg [31:0] rom  [0:4095];
  reg [31:0] pc_;
  reg [11:0] addr;

  // Sub-module1 npc
  reg [31:0] npc;
  always @(*) begin
    case (jumpOp)
      3'd0: begin
        // none
        npc = pc + 4;
      end
      3'd1: begin
        //branch（beq/bgtz/blez/bgez/bltz/bne）
        if (branchEn == 1'b1) begin
          // We have used CMP in D level instead of ALU in E level
          npc = D_pcPlus4 + ({{16{offset[15]}}, offset} << 2);
        end else begin
          npc = pc + 4;
        end
      end
      3'd2: begin
        //j/jal
        npc = {D_pcPlus4[31:28], instr_index, {2{1'b0}}};
      end
      3'd3: begin
        //jr/jalr
        npc = rsIn;
      end
      default: npc = pc + 4;
    endcase
  end

  // Sub-module2 pc
  always @(posedge clk) begin
    if (reset == 1'b1) begin
      pc <= 32'h00003000;
    end else if (enable) begin
      pc <= npc;
    end
  end

  // Sub-module3 im
  // initial begin
  //   $readmemh("code.txt", rom);
  // end
  // always @(*) begin
  //   pc_    = pc - 32'h00003000;
  //   addr   = pc_[13:2];
  //   nInstr = rom[addr];
  // end
endmodule
