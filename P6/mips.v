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
    input          reset,
    input          clk,
    input  [ 31:0] i_inst_rdata,
    input  [ 31:0] m_data_rdata,
    output [ 31:0] i_inst_addr,
    output [ 31:0] m_data_addr,
    output [ 31:0] m_data_wdata,
    output [3 : 0] m_data_byteen,
    output [ 31:0] m_inst_addr,
    output         w_grf_we,
    output [  4:0] w_grf_addr,
    output [ 31:0] w_grf_wdata,
    output [ 31:0] w_inst_addr
);
  // F stage
  wire enableIFU, branchEn;
  wire [31:0] Drs_f, pcPlus4_D, nInstr_F, nInstr_D, pc_F;
  wire [2:0] jumpOpD;

  assign nInstr_F = i_inst_rdata;
  IFU mips_IFU (
      .clk        (clk),
      .reset      (reset),
      .enable     (enableIFU),
      .branchEn   (branchEn),
      .offset     (nInstr_D[`imm16]),
      .instr_index(nInstr_D[`addr26]),
      .rsIn       (Drs_f),
      .D_pcPlus4  (pcPlus4_D),
      .jumpOp     (jumpOpD),
      //outputs
      //.nInstr     (nInstr_F),
      .pc         (pc_F)
  );
  assign i_inst_addr = reset ? 32'h00003000 : pc_F;

  // D stage
  // register
  wire enableD;
  wire [31:0] pc_D, pcPlus8_D;
  IF_ID mips_Dreg (
      .clk      (clk),
      .reset    (reset),
      .enable   (enableD),
      .F_pc     (pc_F),
      .F_nInstr (nInstr_F),
      //outputs
      .pc_D     (pc_D),
      .pcPlus4_D(pcPlus4_D),
      .pcPlus8_D(pcPlus8_D),
      .nInstr_D (nInstr_D)
  );
  // control
  wire [1:0] regDstD, extOpD;
  wire [2:0] branchTypeD;
  Controller mips_CtrlD (
      .nInstr    (nInstr_D),
      .op        (nInstr_D[`op]),
      .fn        (nInstr_D[`fn]),
      //outputs
      .regDst    (regDstD),
      .extOp     (extOpD),
      .jumpOp    (jumpOpD),
      .branchType(branchTypeD)
  );
  // other datapath
  wire [31:0] RD1, RD2, WD, pc_W;
  wire [4:0] A3;
  wire       regWriteW;
  assign w_grf_we    = reset ? 1'b0 : regWriteW;
  assign w_grf_addr  = reset ? 5'd0 : A3;
  assign w_grf_wdata = reset ? 32'd0 : WD;
  assign w_inst_addr = reset ? 32'h00003000 : pc_W;
  GRF mips_GRF (
      .clk  (clk),
      .reset(reset),
      .WE   (regWriteW),
      .A1   (nInstr_D[`rs]),
      .A2   (nInstr_D[`rt]),
      .A3   (A3),
      .WD   (WD),
      .pc   (pc_W),
      //outputs
      .RD1  (RD1),
      .RD2  (RD2)
  );
  wire [31:0] extImmD;
  EXT mips_EXT (
      .dataIn (nInstr_D[`imm16]),
      .extOp  (extOpD),
      //outputs
      .dataOut(extImmD)
  );
  wire [31:0] Drt_f;
  CMP mips_CMP (
      .A         (Drs_f),
      .B         (Drt_f),
      .branchType(branchTypeD),
      //outputs
      .branchEn  (branchEn)
  );

  // E stage
  // register
  wire clearE;
  wire [31:0] nInstr_E, pc_E, pcPlus4_E, pcPlus8_E, rsData_E, rtData_E, extImm_E;
  ID_EX mips_Ereg (
      .clk      (clk),
      .reset    (reset || clearE),
      .enable   (1'b1),
      .D_nInstr (nInstr_D),
      .D_pc     (pc_D),
      .D_pcPlus4(pcPlus4_D),
      .D_pcPlus8(pcPlus8_D),
      .D_RD1    (Drs_f),
      .D_RD2    (Drt_f),
      .D_dataOut(extImmD),
      //outputs
      .nInstr_E (nInstr_E),
      .pc_E     (pc_E),
      .pcPlus4_E(pcPlus4_E),
      .pcPlus8_E(pcPlus8_E),
      .rsData_E (rsData_E),
      .rtData_E (rtData_E),
      .extImm_E (extImm_E)
  );
  //control
  wire aluSrcE, isShamtE, hiWriteE, loWriteE, hiReadE, loReadE, startE;
  wire [2:0] memToRE, mudiOpE;
  wire [3:0] aluOpE;
  Controller mips_CtrlE (
      .nInstr (nInstr_E),
      .op     (nInstr_E[`op]),
      .fn     (nInstr_E[`fn]),
      //outputs
      .aluSrc (aluSrcE),
      .aluOp  (aluOpE),
      .isShamt(isShamtE),
      .mudiOp (mudiOpE),
      .hiWrite(hiWriteE),
      .loWrite(loWriteE),
      .hiRead (hiReadE),
      .loRead (loReadE),
      .start  (startE),
      .memToR (memToRE)
  );
  //other datapath
  wire [31:0] Ert_f, B;
  aluSrc_sel mips_aluSrc_sel (
      .RD2    (Ert_f),
      .dataOut(extImm_E),
      .aluSrc (aluSrcE),
      //outputs
      .B      (B)
  );
  wire [31:0] Ers_f, aluResE;
  wire       zero;
  wire [4:0] shamtE;
  isShamt_sel mips_isShamt_sel (
      .shamt    (nInstr_E[10:6]),
      .rs_4_0   (Ers_f[4:0]),
      .isShamt  (isShamtE),
      //output
      .shamtData(shamtE)
  );
  ALU mips_ALU (
      .A    (Ers_f),
      .B    (B),
      .aluOp(aluOpE),
      .shamt(shamtE),
      //outputs
      .R    (aluResE)
  );
  wire busyE;
  wire [31:0] HIE, LOE, hiloDataE;
  MUDI_Processor mips_MUDIP (
      .clk    (clk),
      .reset  (reset),
      .A      (Ers_f),
      .B      (Ert_f),
      .start  (startE),
      .mudiOp (mudiOpE),
      .hiWrite(hiWriteE),
      .loWrite(loWriteE),
      .hiRead (hiReadE),
      .loRead (loReadE),
      //outputs
      .HI     (HIE),
      .LO     (LOE),
      .busy   (busyE),
      .mudiRD (hiloDataE)
  );

  // M stage
  // register
  wire [31:0] hiloData_M, nInstr_M, pc_M, pcPlus4_M, pcPlus8_M, rtData_M, aluRes_M, extImm_M;
  EX_MEM mips_Mreg (
      .clk       (clk),
      .reset     (reset),
      .enable    (1'b1),
      .E_nInstr  (nInstr_E),
      .E_pc      (pc_E),
      .E_pcPlus4 (pcPlus4_E),
      .E_pcPlus8 (pcPlus8_E),
      .E_rtData  (Ert_f),
      .E_aluRes  (aluResE),
      .E_extImm  (extImm_E),
      .E_hiloData(hiloDataE),
      //outputs
      .nInstr_M  (nInstr_M),
      .pc_M      (pc_M),
      .pcPlus4_M (pcPlus4_M),
      .pcPlus8_M (pcPlus8_M),
      .rtData_M  (rtData_M),
      .aluRes_M  (aluRes_M),
      .extImm_M  (extImm_M),
      .hiloData_M(hiloData_M)
  );
  //control
  wire memReadM, memWriteM;
  wire [1:0] storeOpM;
  wire [2:0] loadOpM;
  Controller mips_CtrlM (
      .nInstr  (nInstr_M),
      .op      (nInstr_M[`op]),
      .fn      (nInstr_M[`fn]),
      //outputs
      .memRead (memReadM),
      .memWrite(memWriteM),
      .storeOp (storeOpM),
      .loadOp  (loadOpM)
  );
  //other datapath
  wire [31:0] Mrt_f, RD;
  assign m_data_wdata = reset ? 32'd0 : (memWriteM && storeOpM == 2'd1) ? {2{Mrt_f[15:0]}} : (memWriteM && storeOpM == 2'd2) ? {4{Mrt_f[7:0]}} : Mrt_f;
  assign m_data_addr  = reset ? 32'd0 : aluRes_M;
  assign m_inst_addr  = reset ? 32'h00003000 : pc_M;
  DM mips_DM (
      .clk         (clk),
      .reset       (reset),
      .WE          (memWriteM),
      .RE          (memReadM),
      .storeOp     (storeOpM),
      .loadOp      (loadOpM),
      .A           (aluRes_M),
      //.pc     (pc_M),
      //.WD     (Mrt_f),
      .m_data_rdata(m_data_rdata),
      //output
      .writeBytesEn(m_data_byteen),
      .RD          (RD)
  );

  // W stage
  //register
  wire [31:0] nInstr_W, pcPlus4_W, pcPlus8_W, rtData_W, aluRes_W, extImm_W, dmData_W, hiloData_W;
  MEM_WB mips_Wreg (
      .clk       (clk),
      .reset     (reset),
      .enable    (1'b1),
      .M_nInstr  (nInstr_M),
      .M_pc      (pc_M),
      .M_pcPlus4 (pcPlus4_M),
      .M_pcPlus8 (pcPlus8_M),
      .M_rtData  (rtData_M),
      .M_aluRes  (aluRes_M),
      .M_extImm  (extImm_M),
      .M_dmData  (RD),
      .M_hiloData(hiloData_M),
      //outputs
      .nInstr_W  (nInstr_W),
      .pc_W      (pc_W),
      .pcPlus4_W (pcPlus4_W),
      .pcPlus8_W (pcPlus8_W),
      .rtData_W  (rtData_W),
      .aluRes_W  (aluRes_W),
      .extImm_W  (extImm_W),
      .dmData_W  (dmData_W),
      .hiloData_W(hiloData_W)
  );
  // control
  wire [1:0] regDstW;
  wire [2:0] memToRW;
  Controller mips_CtrlW (
      .nInstr  (nInstr_W),
      .op      (nInstr_W[`op]),
      .fn      (nInstr_W[`fn]),
      //outputs
      .regDst  (regDstW),
      .regWrite(regWriteW),
      .memToR  (memToRW)
  );
  //other datapath
  regDst_sel mips_regDst_sel (
      .rt    (nInstr_W[`rt]),
      .rd    (nInstr_W[`rd]),
      .regDst(regDstW),
      //output
      .A3    (A3)
  );
  memToR_sel mips_memToR_sel (
      .aluRes    (aluRes_W),
      .dmData    (dmData_W),
      .W_hiloData(hiloData_W),
      .W_pcPlus8 (pcPlus8_W),
      .memToR    (memToRW),
      //output
      .WD        (WD)
  );

  // Haz_Process
  wire [2:0] DrsSel, DrtSel, ErsSel, ErtSel, MrtSel;
  Haz_Processor mips_HazP (
      .D_nInstr (nInstr_D),
      .E_nInstr (nInstr_E),
      .M_nInstr (nInstr_M),
      .W_nInstr (nInstr_W),
      .busy     (busyE),
      // stall logic outputs
      .enableIFU(enableIFU),
      .enableD  (enableD),
      .clearE   (clearE),
      // forward logic outputs
      .DrsSel   (DrsSel),
      .DrtSel   (DrtSel),
      .ErsSel   (ErsSel),
      .ErtSel   (ErtSel),
      .MrtSel   (MrtSel)
  );
  Drs_fsel mips_Drs_fsel (
      .DrsSel    (DrsSel),
      .RD1       (RD1),
      .E_pcPlus8 (pcPlus8_E),
      .M_aluRes  (aluRes_M),
      .M_pcPlus8 (pcPlus8_M),
      .WD        (WD),
      .W_pcPlus8 (pcPlus8_W),
      .E_hiloData(hiloDataE),
      .M_hiloData(hiloData_M),
      //output
      .Drs_f     (Drs_f)
  );
  Drt_fsel mips_Drt_fsel (
      .DrtSel    (DrtSel),
      .RD2       (RD2),
      .E_pcPlus8 (pcPlus8_E),
      .M_aluRes  (aluRes_M),
      .M_pcPlus8 (pcPlus8_M),
      .WD        (WD),
      .W_pcPlus8 (pcPlus8_W),
      .E_hiloData(hiloDataE),
      .M_hiloData(hiloData_M),
      //output
      .Drt_f     (Drt_f)
  );
  Ers_fsel mips_Ers_fsel (
      .ErsSel    (ErsSel),
      .E_rsData  (rsData_E),
      .M_aluRes  (aluRes_M),
      .M_pcPlus8 (pcPlus8_M),
      .WD        (WD),
      .W_pcPlus8 (pcPlus8_W),
      .M_hiloData(hiloData_M),
      //output
      .Ers_f     (Ers_f)
  );
  Ert_fsel mips_Ert_fsel (
      .ErtSel    (ErtSel),
      .E_rtData  (rtData_E),
      .M_aluRes  (aluRes_M),
      .M_pcPlus8 (pcPlus8_M),
      .WD        (WD),
      .W_pcPlus8 (pcPlus8_W),
      .M_hiloData(hiloData_M),
      //output
      .Ert_f     (Ert_f)
  );
  Mrt_fsel mips_Mrt_fsel (
      .MrtSel   (MrtSel),
      .M_rtData (rtData_M),
      .WD       (WD),
      .W_pcPlus8(pcPlus8_W),
      //output
      .Mrt_f    (Mrt_f)
  );
endmodule
