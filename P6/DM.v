`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:34:40 10/31/2023 
// Design Name: 
// Module Name:    DM 
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
module DM (
    input             clk,
    input             reset,
    input             WE,
    input             RE,
    input      [ 1:0] storeOp,
    input      [ 2:0] loadOp,
    input      [31:0] A,
    //input      [31:0] pc,
    //input      [31:0] WD,
    input      [31:0] m_data_rdata,
    output reg [ 3:0] writeBytesEn,
    output reg [31:0] RD
);
  reg     [31:0] ram   [0:4095];
  // real address
  wire    [11:0] addr;
  integer        i = 0;
  // 0-1 bits of input value A
  wire    [ 1:0] A_1_0;
  assign A_1_0 = A[1:0];

  // Sub-module1 store_helper
  always @(*) begin
    if (WE == 1'b0 || reset) begin
      writeBytesEn = 4'b0000;
    end else begin
      writeBytesEn = 4'b0000;
      case (storeOp)
        2'd0: begin  //sw
          writeBytesEn = 4'b1111;
        end
        2'd1: begin  //sh
          writeBytesEn = (A_1_0[1] == 1'b1) ? 4'b1100 : 4'b0011;
        end
        2'd2: begin  //sb
          writeBytesEn = (A_1_0 == 2'b00) ? 4'b0001 : (A_1_0 == 2'b01) ? 4'b0010 : (A_1_0 == 2'b10) ? 4'b0100 : (A_1_0 == 2'b11) ? 4'b1000 : 4'b0000;
        end
        default: begin
          writeBytesEn = 4'b0000;
        end
      endcase
    end
  end

  // Sub-module2 main_dm
  // assign addr = A[13:2];
  // always @(posedge clk) begin
  //   if (reset == 1'b1) begin
  //     for (i = 0; i < 4096; i = i + 1) begin
  //       ram[i] <= 32'd0;
  //     end
  //   end else begin
  //     if (WE == 1'b1) begin
  //       case (writeBytesEn)
  //         4'b0001: begin
  //           ram[addr][7:0] <= WD[7:0];
  //           //$display("%d@%h: *%h <= %h", $time, pc, A / 4 * 4, {ram[addr][31:8], WD[7:0]});
  //           $display("@%h: *%h <= %h", pc, A / 4 * 4, {ram[addr][31:8], WD[7:0]});
  //         end
  //         4'b0010: begin
  //           ram[addr][15:8] <= WD[7:0];
  //           //$display("%d@%h: *%h <= %h", $time, pc, A / 4 * 4, {ram[addr][31:16], WD[7:0], ram[addr][7:0]});
  //           $display("@%h: *%h <= %h", pc, A / 4 * 4, {ram[addr][31:16], WD[7:0], ram[addr][7:0]});
  //         end
  //         4'b0100: begin
  //           ram[addr][23:16] <= WD[7:0];
  //           //$display("%d@%h: *%h <= %h", $time, pc, A / 4 * 4, {ram[addr][31:24], WD[7:0], ram[addr][15:0]});
  //           $display("@%h: *%h <= %h", pc, A / 4 * 4, {ram[addr][31:24], WD[7:0], ram[addr][15:0]});
  //         end
  //         4'b1000: begin
  //           ram[addr][31:24] <= WD[7:0];
  //           //$display("%d@%h: *%h <= %h", $time, pc, A / 4 * 4, {WD[7:0], ram[addr][23:0]});
  //           $display("@%h: *%h <= %h", pc, A / 4 * 4, {WD[7:0], ram[addr][23:0]});
  //         end
  //         4'b0011: begin
  //           ram[addr][15:0] <= WD[15:0];
  //           //$display("%d@%h: *%h <= %h", $time, pc, A / 4 * 4, {ram[addr][31:16], WD[15:0]});
  //           $display("@%h: *%h <= %h", pc, A / 4 * 4, {ram[addr][31:16], WD[15:0]});
  //         end
  //         4'b1100: begin
  //           ram[addr][31:16] <= WD[15:0];
  //           //display for test
  //           //$display("%d@%h: *%h <= %h", $time, pc, A / 4 * 4, {WD[15:0], ram[addr][15:0]});
  //           $display("@%h: *%h <= %h", pc, A / 4 * 4, {WD[15:0], ram[addr][15:0]});
  //         end
  //         4'b1111: begin
  //           ram[addr] <= WD;
  //           //display for test
  //           //$display("%d@%h: *%h <= %h", $time, pc, A / 4 * 4, WD);
  //           $display("@%h: *%h <= %h", pc, A / 4 * 4, WD);
  //         end
  //       endcase
  //     end else begin
  //       ram[addr] <= ram[addr];
  //     end
  //   end
  // end

  // Sub-module3 load_helper
  always @(*) begin
    if (RE == 1) begin
      case (loadOp)
        3'd0: begin  //lw
          RD = m_data_rdata;
        end
        3'd1: begin  //lbu
          case (A_1_0)
            2'b00:   RD = {{24{1'b0}}, m_data_rdata[7:0]};
            2'b01:   RD = {{24{1'b0}}, m_data_rdata[15:8]};
            2'b10:   RD = {{24{1'b0}}, m_data_rdata[23:16]};
            2'b11:   RD = {{24{1'b0}}, m_data_rdata[31:24]};
            default: RD = 32'b0;
          endcase
        end
        3'd2: begin  // lb
          case (A_1_0)
            2'b00:   RD = {{24{m_data_rdata[7]}}, m_data_rdata[7:0]};
            2'b01:   RD = {{24{m_data_rdata[15]}}, m_data_rdata[15:8]};
            2'b10:   RD = {{24{m_data_rdata[23]}}, m_data_rdata[23:16]};
            2'b11:   RD = {{24{m_data_rdata[31]}}, m_data_rdata[31:24]};
            default: RD = 32'b0;
          endcase
        end
        3'd3: begin  //lhu
          case (A_1_0[1])
            1'b0: RD = {{16{1'b0}}, m_data_rdata[15:0]};
            1'b1: RD = {{16{1'b0}}, m_data_rdata[31:16]};
            default: RD = 32'b0;
          endcase
        end
        3'd4: begin  //lh
          case (A_1_0[1])
            1'b0: RD = {{16{m_data_rdata[15]}}, m_data_rdata[15:0]};
            1'b1: RD = {{16{m_data_rdata[31]}}, m_data_rdata[31:16]};
            default: RD = 32'b0;
          endcase
        end
        default: RD = 32'b0;
      endcase
    end else begin
      RD = 32'b0;
    end
  end
endmodule
