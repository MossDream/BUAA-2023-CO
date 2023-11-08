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
  wire beqD, calrD, caliD, loadD, storeD, jrD, jalD;
  Haz_Decoder D_Decoder (
      .nInstr (D_nInstr),
      .isBeq  (beqD),
      .isCalr (calrD),
      .isCali (caliD),
      .isLoad (loadD),
      .isStore(storeD),
      .isJr   (jrD),
      .isJal  (jalD)
  );
  // E stage
  wire beqE, calrE, caliE, loadE, storeE, jrE, jalE;
  Haz_Decoder E_Decoder (
      .nInstr (E_nInstr),
      .isBeq  (beqE),
      .isCalr (calrE),
      .isCali (caliE),
      .isLoad (loadE),
      .isStore(storeE),
      .isJr   (jrE),
      .isJal  (jalE)
  );
  // M stage
  wire beqM, calrM, caliM, loadM, storeM, jrM, jalM;
  Haz_Decoder M_Decoder (
      .nInstr (M_nInstr),
      .isBeq  (beqM),
      .isCalr (calrM),
      .isCali (caliM),
      .isLoad (loadM),
      .isStore(storeM),
      .isJr   (jrM),
      .isJal  (jalM)
  );
  // W stage
  wire beqW, calrW, caliW, loadW, storeW, jrW, jalW;
  Haz_Decoder W_Decoder (
      .nInstr (W_nInstr),
      .isBeq  (beqW),
      .isCalr (calrW),
      .isCali (caliW),
      .isLoad (loadW),
      .isStore(storeW),
      .isJr   (jrW),
      .isJal  (jalW)
  );

  // stall logic
  wire stall_rs;
  wire stall_rt;
  wire stall;
  assign stall_rt = (beqD && loadE && rtE == rtD && rtD) || (beqD && caliE && rtE == rtD && rtD) || (beqD && calrE && rdE == rtD && rtD) || (beqD && loadM && rtM == rtD && rtD) || (calrD && loadE && rtD == rtE && rtE);
  assign stall_rs = (beqD && loadE && rtE == rsD && rsD) ||
                        (beqD && caliE && rtE == rsD && rsD) ||
                        (beqD && calrE && rdE == rsD && rsD) ||
                        (beqD && loadM && rtM == rsD && rsD) ||
                        (calrD && loadE && rsD == rtE && rsD) ||
                        (caliD && loadE && rsD == rtE && rsD) ||
                        (loadD && loadE && rsD == rtE && rsD) ||
                        (storeD && loadE && rsD == rtE && rsD) ||
                        (jrD && loadE && rtE == rsD && rsD) ||
                        (jrD && caliE && rtE == rsD && rsD) ||
                        (jrD && calrE && rdE == rsD && rsD) ||
                        (jrD && loadM && rtM == rsD && rsD);
  assign stall = stall_rs || stall_rt;
  assign enableIFU = ~stall;
  assign enableD = ~stall;
  assign clearE = stall;

  // forward logic  default:0
  assign DrsSel = (rsD == 5'd31 && jalE && rsD) ? 1 : (rsD == rtM && caliM && rsD) || (rsD == rdM && calrM && rsD) ? 2 : (rsD == 5'd31 && jalM && rsD) ? 3 : (rsD == rtW && (loadW || caliW) && rsD) || (rsD == rdW && calrW && rsD) ? 4 : (rsD == 31 && jalW && rsD) ? 5 : 0;
  assign DrtSel = (rtD == 31 && jalE && rtD) ? 1 : (rtD == rtM && caliM && rtD) || (rtD == rdM && calrM && rtD) ? 2 : (rtD == 31 && jalM && rtD) ? 3 : (rtD == rtW && (loadW || caliW) && rtD) || (rtD == rdW && calrW && rtD) ? 4 : (rtD == 31 && jalW && rtD) ? 5 : 0;
  assign ErsSel = (rsE == rtM && caliM && rsE) || (rsE == rdM && calrM && rsE) ? 1 : (rsE == 31 && jalM && rsE) ? 2 : (rsE == rtW && (loadW || caliW) && rsE) || (rsE == rdW && calrW && rsE) ? 3 : (rsE == 31 && jalW && rsE) ? 4 : 0;
  assign ErtSel = (rtE == rtM && caliM && rtE) || (rtE == rdM && calrM && rtE) ? 1 : (rtE == 31 && jalM && rtE) ? 2 : (rtE == rtW && (loadW || caliW) && rtE) || (rtE == rdW && calrW && rtE) ? 3 : (rtE == 31 && jalW && rtE) ? 4 : 0;
  assign MrtSel = (rtM == rtW && (loadW || caliW) && rtM) || (rtM == rdW && calrW && rtM) ? 1 : (rtM == 31 && jalW && rtM) ? 2 : 0;

endmodule
