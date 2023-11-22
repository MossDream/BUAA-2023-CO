`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:35:04 11/08/2023 
// Design Name: 
// Module Name:     Bridge
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
module Bridge (
    input  [31:2] PrAddr,    // CPU传给外设的地址
    input         PrWE,      // CPU传给外设的写使能
    input  [31:0] PrWD,      // CPU传给外设的写数据
    input  [31:0] DEV1_RD,   // 外设1传给CPU的读数据
    input  [31:0] DEV2_RD,   // 外设2传给CPU的读数据
    output [31:0] PrRD,      // 外设传给CPU的CPU读数据
    output [31:2] DEV_Addr,  // CPU传给外设要进行工作的地址
    output [31:0] DEV_WD,    // CPU传给外设要进行写的数据
    output        DEV1_WE,   // CPU传给外设1的写使能
    output        DEV2_WE    // CPU传给外设2的写使能
);
  // 在本次设计中，外设1就是Timer0；外设2就是Timer1
  wire isDEV1, isDEV2;
  // 根据Bridge已有标准判断操作地址是否对应外设所在地址
  assign isDEV1   = (PrAddr[31:4] == 28'h00007F0);
  assign isDEV2   = (PrAddr[31:4] == 28'h00007F1);

  assign PrRD     = (isDEV1) ? DEV1_RD : (isDEV2) ? DEV2_RD : 32'b0;
  assign DEV1_WE  = PrWE && isDEV1;
  assign DEV2_WE  = PrWE && isDEV2;
  assign DEV_Addr = PrAddr;
  assign DEV_WD   = PrWD;

endmodule
