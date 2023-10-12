`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:13:58 10/10/2023 
// Design Name: 
// Module Name:    BlockChecker 
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
`define START 4'd0 //开始准备匹配一个新单词
`define B 4'd1 //当前匹配到序列B
`define BE 4'd2 //当前匹配到序列BE
`define BEG 4'd3 //当前匹配到序列BEG
`define BEGI 4'd4 //当前匹配到序列BEGI
`define BEGIN 4'd5 //当前匹配到序列BEGIN
`define E 4'd6 //当前匹配到序列E
`define EN 4'd7 //当前匹配到序列EN
`define END 4'd8 //当前匹配到序列END
`define OTHER 4'd9 //当前匹配到其他序列
module BlockChecker (
    input            clk,
    input            reset,
    input      [7:0] in,
    output reg       result
);
  reg [ 3:0] state = 0;
  reg [31:0] begin_cnt = 32'b0;
  reg [31:0] end_cnt = 32'b0;
  reg        error = 1'b0;
  initial begin
    result = 1'b1;
  end
  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      state     <= `START;
      result    <= 1'b1;
      begin_cnt <= 32'b0;
      end_cnt   <= 32'b0;
      error     <= 1'b0;
    end else begin
      case (state)
        `START: begin
          if (in == "B" || in == "b") begin
            state <= `B;
          end else if (in == "E" || in == "e") begin
            state <= `E;
          end else if (in == " ") begin
            state <= `START;
          end else begin
            state <= `OTHER;
          end
        end
        `B: begin
          if (in == "E" || in == "e") begin
            state <= `BE;
          end else if (in == " ") begin
            state <= `START;
          end else begin
            state <= `OTHER;
          end
        end
        `BE: begin
          if (in == "G" || in == "g") begin
            state <= `BEG;
          end else if (in == " ") begin
            state <= `START;
          end else begin
            state <= `OTHER;
          end
        end
        `BEG: begin
          if (in == "I" || in == "i") begin
            state <= `BEGI;
          end else if (in == " ") begin
            state <= `START;
          end else begin
            state <= `OTHER;
          end
        end
        `BEGI: begin
          if (in == "N" || in == "n") begin
            state <= `BEGIN;
            begin_cnt = begin_cnt + 32'b1;
            result <= 1'b0;
          end else if (in == " ") begin
            state <= `START;
          end else begin
            state <= `OTHER;
          end
        end
        `BEGIN: begin
          if (in == " ") begin
            state  <= `START;
            result <= 1'b0;
          end else begin
            state <= `OTHER;
            begin_cnt = begin_cnt - 32'b1;
            if ((begin_cnt == end_cnt) && (error == 1'b0)) begin
              result <= 1'b1;
            end else begin
              result <= 1'b0;
            end
          end
        end
        `E: begin
          if (in == "N" || in == "n") begin
            state <= `EN;
          end else if (in == " ") begin
            state <= `START;
          end else begin
            state <= `OTHER;
          end
        end
        `EN: begin
          if (in == "D" || in == "d") begin
            state <= `END;
            end_cnt = end_cnt + 32'b1;
            if ((begin_cnt == end_cnt) && (error == 1'b0)) begin
              result <= 1'b1;
            end else begin
              result <= 1'b0;
            end
          end else if (in == " ") begin
            state <= `START;
          end else begin
            state <= `OTHER;
          end
        end
        `END: begin
          if (in == " ") begin
            state <= `START;
            if (end_cnt > begin_cnt) begin
              error <= 1'b1;
            end
          end else begin
            state <= `OTHER;
            end_cnt = end_cnt - 32'b1;
            if ((begin_cnt == end_cnt) && (error == 1'b0)) begin
              result <= 1'b1;
            end else begin
              result <= 1'b0;
            end
          end
        end
        `OTHER: begin
          if (in == " ") begin
            state <= `START;
          end else begin
            state <= `OTHER;
          end
        end
        default: begin
          result <= 1'b0;
        end
      endcase
    end
  end
endmodule
