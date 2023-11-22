`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:35:04 11/08/2023 
// Design Name: 
// Module Name:     CPU
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
module CPU (
    input clk,   // 时钟信号
    input reset, // 同步复位信号

    // 目前高三位闲置，恒置0；第2位对应外部中断发生器；第1-0位对应Timer1-Timer0
    input [5:0] HWInt,  // 6位硬件中断信号，某位1表示该位对应硬件产生了中断

    output [31:0] macroscopic_pc,  // 宏观 PC

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

    output [31:0] w_inst_addr,  // W 级 PC

    //Bridge 需要的信号
    input  [31:0] PrRD,
    output [31:0] PrWD
);

  assign m_int_addr = m_data_addr;

  // F stage
  wire enableIFU, branchEn, ReqM, eretD;
  wire [31:0] Drs_f, pcPlus4_D, nInstr_F, nInstr_D, pc_F, EPC_f;
  wire [2:0] jumpOpD;

  IFU mips_IFU (
      .clk        (clk),
      .reset      (reset),
      .enable     (enableIFU | ReqM),
      .branchEn   (branchEn),
      .offset     (nInstr_D[`imm16]),
      .instr_index(nInstr_D[`addr26]),
      .rsIn       (Drs_f),
      .D_pcPlus4  (pcPlus4_D),
      .jumpOp     (jumpOpD),
      .ReqM       (ReqM),
      .eretD      (eretD),
      .EPC_f      (EPC_f),
      //outputs
      //.nInstr     (nInstr_F),
      .pc         (pc_F)
  );
  assign i_inst_addr = reset ? 32'h00003000 : pc_F;

  // Exception in F
  wire [4:0] excCodeF;
  // 取指异常
  wire       AdEL;
  assign AdEL     = (pc_F[1:0] != 2'b00) || (pc_F < 32'h3000 || pc_F > 32'h6ffc);
  assign nInstr_F = (AdEL) ? 32'b0 : i_inst_rdata;
  assign excCodeF = (AdEL) ? 5'd4 : 5'd0;

  // D stage
  // register
  wire enableD, BDInD, BDIn_D;
  wire [31:0] pc_D, pcPlus8_D;
  wire [4:0] excCode_D;
  // 特殊识别：eret指令
  assign eretD = (nInstr_D == `full_eret);
  IF_ID mips_Dreg (
      .clk      (clk),
      .reset    (reset | ReqM | eretD),
      .enable   (enableD),
      .F_pc     (pc_F),
      .F_nInstr (nInstr_F),
      .F_BDIn   (BDInD),
      .F_excCode(excCodeF),
      //outputs
      .pc_D     (pc_D),
      .pcPlus4_D(pcPlus4_D),
      .pcPlus8_D(pcPlus8_D),
      .nInstr_D (nInstr_D),
      .BDIn_D   (BDIn_D),
      .excCode_D(excCode_D)
  );
  // control
  wire [1:0] regDstD, extOpD;
  wire [2:0] branchTypeD;
  wire isUnknown, Syscall;
  Controller mips_CtrlD (
      .nInstr    (nInstr_D),
      .op        (nInstr_D[`op]),
      .fn        (nInstr_D[`fn]),
      //outputs
      .regDst    (regDstD),
      .extOp     (extOpD),
      .jumpOp    (jumpOpD),
      .branchType(branchTypeD),
      .BDIn      (BDInD),
      .isUnknown (isUnknown),
      .Syscall   (Syscall)
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

  //Exception in D
  wire [4:0] excCode_D_new;
  assign excCode_D_new = isUnknown ? 5'd10 : Syscall ? 5'd8 : excCode_D;

  // E stage
  // register
  wire clearE, BDIn_E;
  wire [31:0] nInstr_E, pc_E, pcPlus4_E, pcPlus8_E, rsData_E, rtData_E, extImm_E;
  wire [4:0] excCode_E;
  ID_EX mips_Ereg (
      .clk      (clk),
      .reset    (reset || clearE || ReqM),
      .enable   (1'b1),
      .D_nInstr (nInstr_D),
      .D_pc     (pc_D),
      .D_pcPlus4(pcPlus4_D),
      .D_pcPlus8(pcPlus8_D),
      .D_RD1    (Drs_f),
      .D_RD2    (Drt_f),
      .D_dataOut(extImmD),
      .D_BDIn   (BDIn_D),
      .D_excCode(excCode_D_new),
      //outputs
      .nInstr_E (nInstr_E),
      .pc_E     (pc_E),
      .pcPlus4_E(pcPlus4_E),
      .pcPlus8_E(pcPlus8_E),
      .rsData_E (rsData_E),
      .rtData_E (rtData_E),
      .extImm_E (extImm_E),
      .BDIn_E   (BDIn_E),
      .excCode_E(excCode_E)
  );
  //control
  wire aluSrcE, isShamtE, hiWriteE, loWriteE, hiReadE, loReadE, startE, isLoadE, isStoreE;
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
      .memToR (memToRE),
      .isLoad (isLoadE),
      .isStore(isStoreE)
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
  wire overflow;
  ALU mips_ALU (
      .A       (Ers_f),
      .B       (B),
      .aluOp   (aluOpE),
      .shamt   (shamtE),
      //outputs
      .R       (aluResE),
      .overflow(overflow)
  );
  wire busyE;
  wire [31:0] HIE, LOE, hiloDataE;
  MUDI_Processor mips_MUDIP (
      .clk    (clk),
      .reset  (reset),
      .A      (Ers_f),
      .B      (Ert_f),
      .start  (startE_new),
      .mudiOp (mudiOpE),
      .hiWrite(hiWriteE && ~ReqM),
      .loWrite(loWriteE && ~ReqM),
      .hiRead (hiReadE),
      .loRead (loReadE),
      //outputs
      .HI     (HIE),
      .LO     (LOE),
      .busy   (busyE),
      .mudiRD (hiloDataE)
  );

  //Exception in E
  wire Ov, startE_new;
  wire [4:0] excCode_E_new;
  assign Ov            = ((nInstr_E[`op] == `R && (nInstr_E[`fn] == `Add || nInstr_E[`fn] == `Sub)) || nInstr_E[`op] == `Addi) && overflow;
  assign excCode_E_new = Ov ? 5'd12 : (isStoreE && overflow) ? 5'd5 : (isLoadE && overflow) ? 5'd4 : excCode_E;
  assign startE_new    = ReqM ? 0 : startE;

  // M stage
  // register
  wire [31:0] hiloData_M, nInstr_M, pc_M, pcPlus4_M, pcPlus8_M, rtData_M, aluRes_M, extImm_M;
  wire BDIn_M, overflow_M;
  wire [4:0] excCode_M;
  EX_MEM mips_Mreg (
      .clk       (clk),
      .reset     (reset | ReqM),
      .enable    (1'b1),
      .E_nInstr  (nInstr_E),
      .E_pc      (pc_E),
      .E_pcPlus4 (pcPlus4_E),
      .E_pcPlus8 (pcPlus8_E),
      .E_rtData  (Ert_f),
      .E_aluRes  (aluResE),
      .E_extImm  (extImm_E),
      .E_hiloData(hiloDataE),
      .E_BDIn    (BDIn_E),
      .E_excCode (excCode_E_new),
      .E_overflow(overflow),
      //outputs
      .nInstr_M  (nInstr_M),
      .pc_M      (pc_M),
      .pcPlus4_M (pcPlus4_M),
      .pcPlus8_M (pcPlus8_M),
      .rtData_M  (rtData_M),
      .aluRes_M  (aluRes_M),
      .extImm_M  (extImm_M),
      .hiloData_M(hiloData_M),
      .BDIn_M    (BDIn_M),
      .excCode_M (excCode_M),
      .overflow_M(overflow_M)
  );
  //control
  wire memReadM, memWriteM;
  wire [1:0] storeOpM;
  wire [2:0] loadOpM;
  wire isLoadM, isStoreM, CP0_en, SyscallM;
  Controller mips_CtrlM (
      .nInstr      (nInstr_M),
      .op          (nInstr_M[`op]),
      .fn          (nInstr_M[`fn]),
      .waddr       (aluRes_M),
      //outputs
      .memRead     (memReadM),
      .memWrite    (memWriteM),
      .storeOp     (storeOpM),
      .loadOp      (loadOpM),
      .isLoad      (isLoadM),
      .isStore     (isStoreM),
      .CP0_en      (CP0_en),
      .Syscall     (SyscallM),
      .m_int_byteen(m_int_byteen)
  );
  //other datapath
  wire [31:0] Mrt_f, RD;
  assign m_data_wdata = reset ? 32'd0 : (memWriteM && storeOpM == 2'd1) ? {2{Mrt_f[15:0]}} : (memWriteM && storeOpM == 2'd2) ? {4{Mrt_f[7:0]}} : Mrt_f;
  assign m_data_addr  = reset ? 32'd0 : aluRes_M;
  assign m_inst_addr  = reset ? 32'h00003000 : pc_M;
  wire AdEL_;
  DM mips_DM (
      .clk         (clk),
      .reset       (reset),
      .WE          (memWriteM && ~ReqM && ~AdES),
      .RE          (memReadM && ~ReqM && ~AdEL_),
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
  // Exception in M
  wire AdES, AdES1, AdES2, AdEL1_, AdEL2_;

  assign AdES1 = (nInstr_M[`op] == `Sw && aluRes_M[1:0] != 2'b00) || (nInstr_M[`op] == `Sh && (aluRes_M[0] != 1'b0 || aluRes_M >= 32'h3000)) || (nInstr_M[`op] == `Sb && aluRes_M >= 32'h3000);
  assign AdES2 = (isStoreM) && ((overflow_M) || (aluRes_M >= 32'h3000 && aluRes_M != 32'h7f00 && aluRes_M != 32'h7f04 && aluRes_M != 32'h7f10 && aluRes_M != 32'h7f14));
  assign AdES = AdES1 || AdES2;

  assign AdEL1_=(nInstr_M[`op]==`Lw&&aluRes_M[1:0]!=2'b0)||
                  ((nInstr_M[`op]==`Lh||nInstr_M[`op]==`Lhu)&&aluRes_M[0]!=1'b0)||
				 ((nInstr_M[`op]==`Lh||nInstr_M[`op]==`Lhu||nInstr_M[`op]==`Lb||nInstr_M[`op]==`Lbu)&&aluRes_M>=32'h7f00&&aluRes_M<=32'h7f1b)||
				 (isLoadM&&((aluRes_M>=32'h3000&&aluRes_M<32'h7f00)||(aluRes_M>=32'h7f1c)||(aluRes_M>=32'h7f0c&&aluRes_M<32'h7f10)));
  assign AdEL2_ = (isLoadM) && overflow_M;
  assign AdEL_ = AdEL1_ || AdEL2_;
  wire [4:0] excCode_M_new;
  assign excCode_M_new = (|HWInt) ? 5'd0 : (AdEL_) ? 5'd4 : (AdES) ? 5'd5 : excCode_M;

  //Other details
  wire [31:0] RD_new;
  assign RD_new = (aluRes_M <= 32'h2ffc) ? RD : (aluRes_M >= 32'h7f00 && aluRes_M <= 32'h7f1b) ? PrRD : 32'd0;

  //  for CP0 use	
  wire [31:0] pc_M_new;
  assign pc_M_new       = (pc_M != 32'h00003000 || excCode_M) ? pc_M : (pc_E != 32'h00003000 || excCode_E) ? pc_E : (pc_D != 32'h00003000 || excCode_D) ? pc_D : (pc_F != 32'h00003000) ? pc_F : 32'h00003000;
  assign macroscopic_pc = pc_M_new;
  wire BDIn_M_new;
  assign BDIn_M_new = (pc_M != 32'h00003000 || excCode_M) ? BDIn_M : (pc_E != 32'h00003000 || excCode_E) ? BDIn_E : (pc_D != 32'h00003000 || excCode_D) ? BDIn_D : (pc_F != 32'h00003000) ? BDInD : 0;
  assign PrWD       = Mrt_f;

  // CP0
  wire [31:0] CP0Out, EPCOut;
  CP0 mips_CP0 (
      .clk      (clk),
      .reset    (reset),
      .en       (CP0_en && ~ReqM),         // CP0寄存器写使能信号
      .CP0Add   (nInstr_M[`rd]),           // CP0寄存器地址
      .CP0In    (Mrt_f),                   // CP0寄存器写入数据
      .VPC      (pc_M_new),                // 受害PC
      .BDIn     (BDIn_M_new),              // 是否是延迟槽指令
      .ExcCodeIn(excCode_M_new),           // 记录的异常类型编码，详见教程规定
      .HWInt    (HWInt),                   // 6个硬件的中断信号
      .EXLClr   (nInstr_M == `full_eret),  // 用来复位EXL域
      .isSyscall(SyscallM),                // 是否是系统调用
      .CP0Out   (CP0Out),                  // CP0寄存器读出数据
      .EPCOut   (EPCOut),                  // 异常处理结束后需要返回的PC
      .Req      (ReqM)                     // CP0的进入handler程序请求信号
  );
  assign EPC_f = (eretD && nInstr_M[`op] == `COP0 && nInstr_M[`rs] == `mtc0_rs && nInstr_M[`rd] == 5'd14) ? Mrt_f : (eretD && nInstr_E[`op] == `COP0 && nInstr_E[`rs] == `mtc0_rs && nInstr_E[`rd] == 5'd14) ? Ert_f : EPCOut;


  // W stage
  //register
  wire [31:0] nInstr_W, pcPlus4_W, pcPlus8_W, rtData_W, aluRes_W, extImm_W, dmData_W, hiloData_W, CP0Out_W;
  MEM_WB mips_Wreg (
      .clk       (clk),
      .reset     (reset | ReqM),
      .enable    (1'b1),
      .M_nInstr  (nInstr_M),
      .M_pc      (pc_M),
      .M_pcPlus4 (pcPlus4_M),
      .M_pcPlus8 (pcPlus8_M),
      .M_rtData  (rtData_M),
      .M_aluRes  (aluRes_M),
      .M_extImm  (extImm_M),
      .M_dmData  (RD_new),
      .M_hiloData(hiloData_M),
      .M_CP0Out  (CP0Out),
      //outputs
      .nInstr_W  (nInstr_W),
      .pc_W      (pc_W),
      .pcPlus4_W (pcPlus4_W),
      .pcPlus8_W (pcPlus8_W),
      .rtData_W  (rtData_W),
      .aluRes_W  (aluRes_W),
      .extImm_W  (extImm_W),
      .dmData_W  (dmData_W),
      .hiloData_W(hiloData_W),
      .CP0Out_W  (CP0Out_W)
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
      .W_CP0Out  (CP0Out_W),
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
