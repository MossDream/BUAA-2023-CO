`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:26:04 11/06/2023 
// Design Name: 
// Module Name:    Haz_Processor 
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
module Haz_Processor (
    input  [31:0] D_nInstr,
    input  [31:0] E_nInstr,
    input  [31:0] M_nInstr,
    input  [31:0] W_nInstr,
    input         busy,
    // stall logic outputs
    output        enableIFU,
    output        enableD,
    output        clearE,
    // forward logic outputs
    output [ 2:0] DrsSel,
    output [ 2:0] DrtSel,
    output [ 2:0] ErsSel,
    output [ 2:0] ErtSel,
    output [ 2:0] MrtSel
);
  // register Address information
  wire [4:0] rsD, rsE, rtD, rtE, rsM, rtM, rdM, rsW, rtW, rdW, rdE;
  assign rsD = D_nInstr[`rs];
  assign rtD = D_nInstr[`rt];
  assign rsE = E_nInstr[`rs];
  assign rdE = E_nInstr[`rd];
  assign rtE = E_nInstr[`rt];
  assign rsM = M_nInstr[`rs];
  assign rtM = M_nInstr[`rt];
  assign rdM = M_nInstr[`rd];
  assign rsW = W_nInstr[`rs];
  assign rtW = W_nInstr[`rt];
  assign rdW = W_nInstr[`rd];

  // Decoders information
  // D stage
  wire branchD, calrD, caliD, loadD, storeD, jrD, jalD, jalrD, allmudiD, calmudiD, readhlD, writehlD;
  Haz_Decoder D_Decoder (
      .nInstr (D_nInstr),
      .cali   (caliD),
      .calr   (calrD),
      .calmudi(calmudiD),
      .store  (storeD),
      .load   (loadD),
      .branch (branchD),
      .writehl(writehlD),
      .readhl (readhlD),
      // additional
      .allmudi(allmudiD),
      .Jr     (jrD),
      .Jalr   (jalrD),
      .Jal    (jalD)
  );
  // E stage
  wire branchE, calrE, caliE, loadE, storeE, jrE, jalE, jalrE, allmudiE, calmudiE, readhlE;
  Haz_Decoder E_Decoder (
      .nInstr (E_nInstr),
      .cali   (caliE),
      .calr   (calrE),
      .calmudi(calmudiE),
      .store  (storeE),
      .load   (loadE),
      .branch (branchE),
      .readhl (readhlE),
      // additional
      .allmudi(allmudiE),
      .Jr     (jrE),
      .Jalr   (jalrE),
      .Jal    (jalE)
  );
  // M stage
  wire branchM, calrM, caliM, loadM, storeM, jrM, jalM, jalrM, allmudiM, calmudiM, readhlM;
  Haz_Decoder M_Decoder (
      .nInstr (M_nInstr),
      .cali   (caliM),
      .calr   (calrM),
      .calmudi(calmudiM),
      .store  (storeM),
      .load   (loadM),
      .branch (branchM),
      .readhl (readhlM),
      // additional
      .allmudi(allmudiM),
      .Jr     (jrM),
      .Jalr   (jalrM),
      .Jal    (jalM)
  );
  // W stage
  wire branchW, calrW, caliW, loadW, storeW, jrW, jalW, jalrW, allmudiW, calmudiW, readhlW;
  Haz_Decoder W_Decoder (
      .nInstr (W_nInstr),
      .cali   (caliW),
      .calr   (calrW),
      .calmudi(calmudiW),
      .store  (storeW),
      .load   (loadW),
      .branch (branchW),
      .readhl (readhlW),
      // additional
      .allmudi(allmudiW),
      .Jr     (jrW),
      .Jalr   (jalrW),
      .Jal    (jalW)
  );

  // stall logic
  wire stall_rs;
  wire stall_rt;
  wire stall_mudi;
  wire stall;
  assign stall_rt = (branchD && loadE && rtE == rtD && rtD) || (branchD && caliE && rtE == rtD && rtD) || (branchD && calrE && rdE == rtD && rtD) || (branchD && loadM && rtM == rtD && rtD) || (calrD && loadE && rtD == rtE && rtE) || (calmudiD && loadE && rtD == rtE && rtD);
  assign stall_rs = (branchD && loadE && rtE == rsD && rsD) ||
                        (branchD && caliE && rtE == rsD && rsD) ||
                        (branchD && calrE && rdE == rsD && rsD) ||
                        (branchD && loadM && rtM == rsD && rsD) ||
                        (calrD && loadE && rsD == rtE && rsD) ||
                        (caliD && loadE && rsD == rtE && rsD) ||
                        (loadD && loadE && rsD == rtE && rsD) ||
                        (storeD && loadE && rsD == rtE && rsD) ||
                        (calmudiD && loadE && rsD==rtE && rsD) ||
                        (jrD && loadE && rtE == rsD && rsD) ||
                        (jrD && caliE && rtE == rsD && rsD) ||
                        (jrD && calrE && rdE == rsD && rsD) ||
                        (jrD && loadM && rtM == rsD && rsD)||
                        ((jalrD || writehlD) && loadE && rtE == rsD && rsD)||
                        (jalrD && caliE && rtE==rsD && rsD)||
                        (jalrD && calrE && rdE==rsD && rsD)||
                        (jalrD && loadM && rtM==rsD && rsD);
  assign stall_mudi = (allmudiD && busy) || (allmudiD && calmudiE);
  assign stall = stall_rs || stall_rt || stall_mudi;
  assign enableIFU = ~stall;
  assign enableD = ~stall;
  assign clearE = stall;

  // forward logic  default:0
  assign DrsSel = (rsD == rdE && readhlE && rsD) ? 1 : (rsD == 5'd31 && jalE && rsD || rsD == rdE && jalrE && rsD) ? 2 : (rsD == rtM && (caliM||loadM) && rsD) || (rsD == rdM && calrM && rsD) ? 3 : (rsD == 5'd31 && jalM && rsD || rsD == rdM&& jalrM && rsD) ? 4 : (rsD==rdM && readhlM && rsD)? 5 :(rsD == rtW && (loadW || caliW) && rsD) || (rsD == rdW && calrW && rsD) || (rsD==rdW && readhlW && rsD)? 6 : (rsD == 31 && jalW && rsD|| rsD==rdW && jalrW && rsD) ? 7 : 0;
  assign DrtSel = (rtD == rdE && readhlE && rtD) ? 1 : (rtD == 5'd31 && jalE && rtD || rtD == rdE && jalrE && rtD) ? 2 : (rtD == rtM && (caliM||loadM) && rtD) || (rtD == rdM && calrM && rtD) ? 3 : (rtD == 5'd31 && jalM && rtD || rtD == rdM&& jalrM && rtD) ? 4 : (rtD==rdM && readhlM && rtD)? 5 :(rtD == rtW && (loadW || caliW) && rtD) || (rtD == rdW && calrW && rtD) || (rtD==rdW && readhlW && rtD)? 6 : (rtD == 31 && jalW && rtD|| rtD==rdW && jalrW && rtD) ? 7 : 0;
  assign ErsSel = (rsE == rtM && (caliM || loadM) && rsE) || (rsE == rdM && calrM && rsE) ? 1 : (rsE == 31 && jalM && rsE || rsE == rdM && jalrM && rsE) ? 2 : (rsE == rdM && readhlM && rsE ) ? 3 : (rsE == rtW && (loadW || caliW) && rsE) || (rsE == rdW && calrW && rsE) || (rsE == rdW && readhlW && rsE) ? 4 : (rsE == 31 && jalW && rsE||rsE == rdW && jalrW && rsE) ? 5 : 0;
  assign ErtSel = (rtE == rtM && (caliM || loadM) && rtE) || (rtE == rdM && calrM && rtE) ? 1 : (rtE == 31 && jalM && rtE || rtE == rdM && jalrM && rtE) ? 2 : (rtE == rdM && readhlM && rtE ) ? 3 : (rtE == rtW && (loadW || caliW) && rtE) || (rtE == rdW && calrW && rtE) || (rtE == rdW && readhlW && rtE) ? 4 : (rtE == 31 && jalW && rtE||rtE == rdW && jalrW && rtE) ? 5 : 0;
  assign MrtSel = (rtM == rtW && (loadW || caliW) && rtM) || (rtM == rdW && calrW && rtM) || (rtM == rdW && readhlW && rtM) ? 1 : (rtM == 31 && jalW && rtM || rtM == rdW && jalrW && rtM) ? 2 : 0;

endmodule
