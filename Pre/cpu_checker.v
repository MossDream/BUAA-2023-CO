`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:24:20 08/16/2023 
// Design Name: 
// Module Name:    cpu_checker 
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
//status
`define S0 4'b0000
`define S1 4'b0001
`define S2 4'b0010
`define S3 4'b0011
`define S4 4'b0100
`define S5 4'b0101
`define S6 4'b0110
`define S7 4'b0111
`define S8 4'b1000
`define S9 4'b1001
`define S10 4'b1010
`define S11 4'b1011
`define S12 4'b1100
`define S13 4'b1101
`define S14 4'b1110
module cpu_checker (
    input         clk,
    input         reset,
    input  [ 7:0] char,
    input  [15:0] freq,
    output [ 1:0] format_type,
    output [ 3:0] error_code
);
  reg     [3:0] status = `S0;
  reg     [2:0] decimalCnt = 3'b000;
  reg     [3:0] hexCnt = 4'b0000;
  reg           isRegInfo = 1'b0;
  integer       time_ = 0;
  integer       grf_ = 0;
  integer       pc_ = 0;
  integer       addr_ = 0;
  wire isDecimal, isHex;
  assign isDecimal = (char >= "0" && char <= "9") ? 1'b1 : 1'b0;
  assign isHex     = ((char >= "0" && char <= "9") || (char >= "a" && char <= "f")) ? 1'b1 : 1'b0;
  always @(posedge clk) begin
    if (reset == 1'b1) begin  // Reset
      status     <= `S0;
      decimalCnt <= 3'b000;
      hexCnt     <= 4'b0000;
      isRegInfo  <= 1'b0;
      time_      <= 0;
      grf_       <= 0;
      pc_        <= 0;
      addr_      <= 0;
    end else begin
      case (status)
        `S0: begin
          if (char == "^") status <= `S1;
          else status <= `S0;
        end
        `S1: begin
          if (isDecimal == 1'b1) begin
            decimalCnt <= 3'b001;
            status     <= `S2;
            time_ = char - "0";
          end else if (char == "^") status <= `S1;
          else status <= `S0;
        end
        `S2: begin  //reading time
          //进行以下检查：time必须是freq一半的整数倍。（保证周期均为2的正整数次幂）
          if (char == "@") status <= `S3;
          else if (isDecimal == 1'b1) begin
            decimalCnt <= decimalCnt + 3'b001;
            if (decimalCnt + 3'b001 <= 3'b100) begin
              status <= `S2;
              time_  <= time_ + time_ + time_ + time_ + time_ + time_ + time_ + time_ + time_ + time_ + (char - "0");
            end  //非阻塞赋值
            else status <= `S0;
          end else if (char == "^") status <= `S1;
          else status <= `S0;
        end
        `S3: begin
          if (isHex == 1'b1) begin
            hexCnt <= 4'b0001;
            status <= `S4;
            if (char == "a") begin
              pc_ <= 10;
            end else if (char == "b") begin
              pc_ <= 11;
            end else if (char == "c") begin
              pc_ <= 12;
            end else if (char == "d") begin
              pc_ <= 13;
            end else if (char == "e") begin
              pc_ <= 14;
            end else if (char == "f") begin
              pc_ <= 15;
            end else begin
              pc_ <= char - "0";
            end
          end else if (char == "^") status <= `S1;
          else status <= `S0;
        end
        `S4: begin  //reading pc
          if (char == ":") begin
            if (hexCnt == 4'b1000) status <= `S5;
            else status <= `S0;
          end else if (isHex == 1'b1) begin
            hexCnt <= hexCnt + 4'b0001;
            if (hexCnt + 4'b0001 <= 4'b1000) begin
              status <= `S4;
              if (char == "a") begin
                pc_ <= pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + 10;
              end else if (char == "b") begin
                pc_ <= pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + 11;
              end else if (char == "c") begin
                pc_ <= pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + 12;
              end else if (char == "d") begin
                pc_ <= pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + 13;
              end else if (char == "e") begin
                pc_ <= pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + 14;
              end else if (char == "f") begin
                pc_ <= pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + 15;
              end else begin
                pc_ <= pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + pc_ + (char - "0");
              end
            end  //非阻塞赋值
            else status <= `S0;
          end else if (char == "^") status <= `S1;
          else status <= `S0;
        end
        `S5: begin
          if (char == "$") status <= `S6;
          else if (char == " ") status <= `S5;
          else if (char == 8'd42) status <= `S7;
          else if (char == "^") status <= `S1;
          else status <= `S0;
        end
        `S6: begin
          isRegInfo <= 1'b1;
          if (isDecimal == 1'b1) begin
            decimalCnt <= 3'b001;
            status     <= `S8;
            grf_       <= char - "0";
          end else if (char == "^") status <= `S1;
          else status <= `S0;
        end
        `S7: begin
          isRegInfo <= 1'b0;
          if (isHex == 1'b1) begin
            hexCnt <= 4'b0001;
            status <= `S9;
            if (char == "a") begin
              addr_ <= 10;
            end else if (char == "b") begin
              addr_ <= 11;
            end else if (char == "c") begin
              addr_ <= 12;
            end else if (char == "d") begin
              addr_ <= 13;
            end else if (char == "e") begin
              addr_ <= 14;
            end else if (char == "f") begin
              addr_ <= 15;
            end else begin
              addr_ <= char - "0";
            end
          end else if (char == "^") status <= `S1;
          else status <= `S0;
        end
        `S8: begin  //reading  grf
          if (char == " ") status <= `S10;
          else if (char == "<") status <= `S11;
          else if (isDecimal == 1'b1) begin
            decimalCnt <= decimalCnt + 3'b001;
            if (decimalCnt + 3'b001 <= 3'b100) begin
              status <= `S8;
              grf_   <= grf_ + grf_ + grf_ + grf_ + grf_ + grf_ + grf_ + grf_ + grf_ + grf_ + (char - "0");
            end else status <= `S0;
          end else if (char == "^") status <= `S1;
          else status <= `S0;
        end
        `S9: begin  //  reading  addr
          if (char == " " || char == "<") begin
            if (hexCnt == 4'b1000) begin
              if (char == " ") status <= `S10;
              else status <= `S11;
            end else status <= `S0;
          end else if (isHex == 1'b1) begin
            hexCnt <= hexCnt + 4'b0001;
            if (hexCnt + 4'b0001 <= 4'b1000) begin
              status <= `S9;
              if (char == "a") begin
                addr_ <= addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + 10;
              end else if (char == "b") begin
                addr_ <= addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + 11;
              end else if (char == "c") begin
                addr_ <= addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + 12;
              end else if (char == "d") begin
                addr_ <= addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + 13;
              end else if (char == "e") begin
                addr_ <= addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + 14;
              end else if (char == "f") begin
                addr_ <= addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + 15;
              end else begin
                addr_ <= addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + addr_ + (char - "0");
              end
            end else status <= `S0;
          end else if (char == "^") status <= `S1;
          else status <= `S0;
        end
        `S10: begin
          if (char == "<") status <= `S11;
          else if (char == " ") status <= `S10;
          else if (char == "^") status <= `S1;
          else status <= `S0;
        end
        `S11: begin
          if (char == "=") status <= `S12;
          else if (char == "^") status <= `S1;
          else status <= `S0;
        end
        `S12: begin
          if (isHex == 1'b1) begin
            hexCnt <= 4'b0001;
            status <= `S13;
          end else if (char == " ") status <= `S12;
          else if (char == "^") status <= `S1;
          else status <= `S0;
        end
        `S13: begin  //  reading  data
          if (char == "#") begin
            if (hexCnt == 4'b1000) status <= `S14;
            else status <= `S0;
          end else if (isHex == 1'b1) begin
            hexCnt <= hexCnt + 4'b0001;
            if (hexCnt + 4'b0001 <= 4'b1000) status <= `S13;
            else status <= `S0;
          end else if (char == "^") status <= `S1;
          else status <= `S0;
        end
        `S14: begin
          if (char == "^") status <= `S1;
          else status <= `S0;
        end
        default: status <= `S0;
      endcase
    end
  end
  assign format_type   = (status == `S14) ? ((isRegInfo == 1'b1) ? 2'b01 : 2'b10) : 2'b00;
  assign error_code[3] = (status != `S14) ? 1'b0 : (isRegInfo == 1'b0) ? 1'b0 : (grf_ >= 0 && grf_ <= 31) ? 1'b0 : 1'b1;
  assign error_code[2] = (status != `S14) ? 1'b0 : (isRegInfo == 1'b1) ? 1'b0 : (addr_ < 0 || addr_ > 12287) ? 1'b1 : (addr_ & 1 == 1) ? 1'b1 : ((addr_ >>> 1) & 1 == 1) ? 1'b1 : 1'b0;
  assign error_code[1] = (status != `S14) ? 1'b0 : (pc_ < 12288 || pc_ > 20479) ? 1'b1 : (pc_ & 1 == 1) ? 1'b1 : ((pc_ >>> 1) & 1 == 1) ? 1'b1 : 1'b0;
  assign error_code[0] = (status != `S14) ? 1'b0 : ((time_ & ((freq >>> 1) - 1)) == 0) ? 1'b0 : 1'b1;
endmodule
