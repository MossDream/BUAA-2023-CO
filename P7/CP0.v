`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:35:04 11/08/2023 
// Design Name: 
// Module Name:     CP0
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
// 这些都是教程中规定的功能域定义
`define IM SR[15:10]    
`define EXL SR[1]       
`define IE SR[0]       
`define BD Cause[31]    
`define IP Cause[15:10] 
`define ExcCode Cause[6:2]

module CP0 (
    input         clk,
    input         reset,
    input         en,         // CP0寄存器写使能信号
    input  [ 4:0] CP0Add,     // CP0寄存器地址
    input  [31:0] CP0In,      // CP0寄存器写入数据
    input  [31:0] VPC,        // 受害PC
    input         BDIn,       // 是否是延迟槽指令
    input  [ 4:0] ExcCodeIn,  // 记录的异常类型编码，详见教程规定
    input  [ 5:0] HWInt,      // 6个硬件的中断信号
    input         EXLClr,     // 用来复位EXL域
    input         isSyscall,  // 是否是系统调用
    output [31:0] CP0Out,     // CP0寄存器读出数据
    output [31:0] EPCOut,     // 异常处理结束后需要返回的PC
    output        Req         // CP0的进入handler程序请求信号
);
  //教程中规定的三个寄存器
  reg [31:0] SR;
  reg [31:0] Cause;
  reg [31:0] EPC;

  // Req信号生成逻辑
  wire IntReq, ExcReq;
  assign IntReq = ~`EXL & `IE & (|(HWInt & `IM));
  assign ExcReq = ~`EXL & (|ExcCodeIn);
  assign Req    = IntReq | ExcReq | isSyscall;

  // 读CP0寄存器的逻辑  
  assign CP0Out = (CP0Add == 12) ? SR : (CP0Add == 13) ? Cause : (CP0Add == 14) ? EPC : 0;

  // EPCout的生成逻辑
  always @(posedge clk) begin
    if (reset) begin
      SR    <= 0;
      Cause <= 0;
      EPC   <= 0;
    end else begin
      if (EXLClr) begin
        `EXL <= 0;
      end else if (Req) begin
        `ExcCode <= IntReq ? 5'd0 : ExcCodeIn;
        `IP      <= HWInt;
        `EXL     <= 1;
        EPC      <= (BDIn ? VPC - 4 : VPC);
        `BD      <= BDIn;
      end else if (en) begin
        case (CP0Add)
          12: SR <= CP0In;
          14: EPC <= isSyscall ? VPC + 4 : CP0In;
        endcase
      end
    end
  end
  assign EPCOut = EPC;
endmodule
