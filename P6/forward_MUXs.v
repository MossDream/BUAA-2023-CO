`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:16:04 11/08/2023 
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
module Drs_fsel (
    input      [ 2:0] DrsSel,
    input      [31:0] RD1,
    input      [31:0] E_pcPlus8,
    input      [31:0] M_aluRes,
    input      [31:0] M_pcPlus8,
    input      [31:0] WD,
    input      [31:0] W_pcPlus8,
    input      [31:0] E_hiloData,
    input      [31:0] M_hiloData,
    output reg [31:0] Drs_f
);
  always @(*) begin
    case (DrsSel)
      3'd0: Drs_f = RD1;
      3'd1: Drs_f = E_hiloData;
      3'd2: Drs_f = E_pcPlus8;
      3'd3: Drs_f = M_aluRes;
      3'd4: Drs_f = M_pcPlus8;
      3'd5: Drs_f = M_hiloData;
      3'd6: Drs_f = WD;
      3'd7: Drs_f = W_pcPlus8;
      default: Drs_f = 0;
    endcase
  end
endmodule

module Drt_fsel (
    input      [ 2:0] DrtSel,
    input      [31:0] RD2,
    input      [31:0] E_pcPlus8,
    input      [31:0] M_aluRes,
    input      [31:0] M_pcPlus8,
    input      [31:0] WD,
    input      [31:0] W_pcPlus8,
    input      [31:0] E_hiloData,
    input      [31:0] M_hiloData,
    output reg [31:0] Drt_f
);
  always @(*) begin
    case (DrtSel)
      3'd0: Drt_f = RD2;
      3'd1: Drt_f = E_hiloData;
      3'd2: Drt_f = E_pcPlus8;
      3'd3: Drt_f = M_aluRes;
      3'd4: Drt_f = M_pcPlus8;
      3'd5: Drt_f = M_hiloData;
      3'd6: Drt_f = WD;
      3'd7: Drt_f = W_pcPlus8;
      default: Drt_f = 0;
    endcase
  end
endmodule

module Ers_fsel (
    input      [ 2:0] ErsSel,
    input      [31:0] E_rsData,
    input      [31:0] M_aluRes,
    input      [31:0] M_pcPlus8,
    input      [31:0] WD,
    input      [31:0] W_pcPlus8,
    input      [31:0] M_hiloData,
    output reg [31:0] Ers_f
);
  always @(*) begin
    case (ErsSel)
      3'd0: Ers_f = E_rsData;
      3'd1: Ers_f = M_aluRes;
      3'd2: Ers_f = M_pcPlus8;
      3'd3: Ers_f = M_hiloData;
      3'd4: Ers_f = WD;
      3'd5: Ers_f = W_pcPlus8;
      default: Ers_f = 0;
    endcase
  end
endmodule

module Ert_fsel (
    input      [ 2:0] ErtSel,
    input      [31:0] E_rtData,
    input      [31:0] M_aluRes,
    input      [31:0] M_pcPlus8,
    input      [31:0] WD,
    input      [31:0] W_pcPlus8,
    input      [31:0] M_hiloData,
    output reg [31:0] Ert_f
);
  always @(*) begin
    case (ErtSel)
      3'd0: Ert_f = E_rtData;
      3'd1: Ert_f = M_aluRes;
      3'd2: Ert_f = M_pcPlus8;
      3'd3: Ert_f = M_hiloData;
      3'd4: Ert_f = WD;
      3'd5: Ert_f = W_pcPlus8;
      default: Ert_f = 0;
    endcase
  end
endmodule

module Mrt_fsel (
    input      [ 2:0] MrtSel,
    input      [31:0] M_rtData,
    input      [31:0] WD,
    input      [31:0] W_pcPlus8,
    output reg [31:0] Mrt_f
);
  always @(*) begin
    case (MrtSel)
      3'd0: Mrt_f = M_rtData;
      3'd1: Mrt_f = WD;
      3'd2: Mrt_f = W_pcPlus8;
      default: Mrt_f = 0;
    endcase
  end
endmodule
