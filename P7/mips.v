`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:35:04 11/08/2023 
// Design Name: 
// Module Name:     mips
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
`include "Define.v"
module mips (
    input         clk,            // 时钟信号
    input         reset,          // 同步复位信号
    input         interrupt,      // 外部中断信号
    output [31:0] macroscopic_pc, // 宏观 PC

    output [31:0] i_inst_addr,  // IM 读取地址（取指 PC）
    input  [31:0] i_inst_rdata, // IM 读取数据

    output [ 31:0] m_data_addr,   // DM 读写地址
    input  [ 31:0] m_data_rdata,  // DM 读取数据
    output [ 31:0] m_data_wdata,  // DM 待写入数据
    output [3 : 0] m_data_byteen, // DM 字节使能信号

    output [ 31:0] m_int_addr,   // 中断发生器待写入地址
    output [3 : 0] m_int_byteen, // 中断发生器字节使能信号

    output [31:0] m_inst_addr,  // M 级 PC

    output         w_grf_we,    // GRF 写使能信号
    output [4 : 0] w_grf_addr,  // GRF 待写入寄存器编号
    output [ 31:0] w_grf_wdata, // GRF 待写入数据

    output [31:0] w_inst_addr  // W 级 PC
);
  wire PrWE, DEV1_WE, DEV2_WE, IRQ0, IRQ1;
  assign PrWE = (m_data_byteen == 4'd0) ? 1'b0 : 1'b1;
  wire [31:0] PrWD, TC0Out, TC1Out, PrRD, DEV_WD;
  wire [31:2] DEV_Addr;  // CPU传给外设要进行工作的地址
  // Timers
  TC Timer0 (
      .clk  (clk),
      .reset(reset),
      .Addr (DEV_Addr),
      .WE   (DEV1_WE),
      .Din  (DEV_WD),
      //outputs
      .Dout (TC0Out),
      .IRQ  (IRQ0)
  );
  TC Timer1 (
      .clk  (clk),
      .reset(reset),
      .Addr (DEV_Addr),
      .WE   (DEV2_WE),
      .Din  (DEV_WD),
      //outputs
      .Dout (TC1Out),
      .IRQ  (IRQ1)
  );

  // CPU
  CPU mips_CPU (
      .clk  (clk),   // 时钟信号
      .reset(reset), // 同步复位信号

      // 目前高三位闲置，恒置0；第2位对应外部中断发生器；第1-0位对应Timer1-Timer0
      .HWInt         ({3'b0, interrupt, IRQ1, IRQ0}),  // 6位硬件中断信号，某位1表示该位对应硬件产生了中断
      .i_inst_rdata  (i_inst_rdata),                   // IM 读取数据
      .m_data_rdata  (m_data_rdata),                   // DM 读取数据
      .PrRD          (PrRD),
      //outputs
      .macroscopic_pc(macroscopic_pc),                 // 宏观 PC
      .i_inst_addr   (i_inst_addr),                    // IM 读取地址（取指 PC）
      .m_data_addr   (m_data_addr),                    // DM 读写地址
      .m_data_wdata  (m_data_wdata),                   // DM 待写入数据
      .m_data_byteen (m_data_byteen),                  // DM 字节使能信号
      .m_int_addr    (m_int_addr),                     // 中断发生器待写入地址
      .m_int_byteen  (m_int_byteen),                   // 中断发生器字节使能信号
      .m_inst_addr   (m_inst_addr),                    // M 级 PC
      .w_grf_we      (w_grf_we),                       // GRF 写使能信号
      .w_grf_addr    (w_grf_addr),                     // GRF 待写入寄存器编号
      .w_grf_wdata   (w_grf_wdata),                    // GRF 待写入数据
      .w_inst_addr   (w_inst_addr),                    // W 级 PC
      //Bridge 需要的信号
      .PrWD          (PrWD)
  );

  // Bridge
  Bridge mips_Bridge (
      .PrAddr  (m_data_addr[31:2]),  // CPU传给外设的地址
      .PrWE    (PrWE),               // CPU传给外设的写使能
      .PrWD    (PrWD),               // CPU传给外设的写数据
      .DEV1_RD (TC0Out),             // 外设1传给CPU的读数据
      .DEV2_RD (TC1Out),             // 外设2传给CPU的读数据
      // outputs
      .PrRD    (PrRD),               // 外设传给CPU的CPU读数据
      .DEV_Addr(DEV_Addr),           // CPU传给外设要进行工作的地址
      .DEV_WD  (DEV_WD),             // CPU传给外设要进行写的数据
      .DEV1_WE (DEV1_WE),            // CPU传给外设1的写使能
      .DEV2_WE (DEV2_WE)             // CPU传给外设2的写使能
  );
endmodule
