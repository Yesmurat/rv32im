module datapath (input logic clk, clr,
                // Control signals
                input logic RegWriteD,
                input logic [1:0] ResultSrcD,
                input logic MemWriteD,
                input logic JumpD,
                input logic BranchD,
                input logic [3:0] ALUControlD,
                input logic ALUSrcD,
                input logic [2:0] ImmSrcD,
                input logic SrcAsrcD,
                input logic [2:0] funct3D,
                input logic jumpRegD,
                input logic is_M,
                
                // input signals from Hazard Unit
                input logic StallF, StallD, FlushD, FlushE,
                input logic [1:0] ForwardAE, ForwardBE,

                input logic [31:0] RD_instr, RD_data,

                // outputs
                output logic [31:0] PCF, // input for Instruction Memory
                output logic [31:0] ALUResultM, WriteDataM, // inputs to Data Memory
                output logic MemWriteM, // we signal for data memory
                output logic [31:0] InstrD, // input to Control Unit
                output logic [3:0] byteEnable, // input to data memory

                // outputs to Hazard Unit
                output logic [4:0] Rs1D, Rs2D, // outputs from ID stage
                output logic [4:0] Rs1E, Rs2E,
                output logic [4:0] RdE, // outputs from EX stage
                output logic PCSrcE, ResultSrcE_zero, RegWriteM, RegWriteW,
                output logic [4:0] RdM, // output from MEM stage
                output logic [4:0] RdW // output from WB stage

);  
    // PC mux
    logic [31:0] PCPlus4F, PCTargetE, PCF_new;
    logic PCSrcE_int;
    logic [31:0] PCF_int;
    assign PCSrcE = PCSrcE_int;
    assign PCF = PCF_int;

    mux2 pcmux(
        .d0(PCPlus4F),
        .d1(PCTargetE),
        .s(PCSrcE_int),
        .y(PCF_new)
    );

    // Instruction Fetch (IF) stage
    IFregister ifreg(
        .clk(clk),
        .en(~StallF),
        .clr(clr),
        .d(PCF_new),
        .q(PCF_int)
    );

    adder pcplus4(
        .a(PCF_int),
        .b(32'd4),
        .y(PCPlus4F)
    );


    // Instruction Decode (ID) stage
    logic [31:0] PCD, PCPlus4D;
    logic [31:0] RD1, RD2;
    logic [31:0] ResultW;
    logic [31:0] ImmExtD;
    logic [4:0] RdD;

    logic [31:0] InstrD_int;
    assign InstrD = InstrD_int;

    logic [4:0] Rs1D_int, Rs2D_int;
    assign Rs1D = Rs1D_int;
    assign Rs2D = Rs2D_int;

    assign Rs1D_int = InstrD_int[19:15];
    assign Rs2D_int = InstrD_int[24:20];
    assign RdD = InstrD_int[11:7];

    IFIDregister ifidreg(
        .clk(clk),
        .clr(FlushD | clr),
        .en(~StallD),
        .RD_instr(RD_instr), .PCF(PCF_int), .PCPlus4F(PCPlus4F),
        .InstrD(InstrD_int), .PCD(PCD), .PCPlus4D(PCPlus4D)
    );
	 
	logic RegWriteW_int;
    assign RegWriteW = RegWriteW_int;

    regfile rf(
        .clk(clk), .we3(RegWriteW_int), .clr(clr),
        .a1(Rs1D_int), .a2(Rs2D_int), .a3(RdW),
        .wd3(ResultW), .rd1(RD1), .rd2(RD2)
    );

    extend ext(
        .instr(InstrD_int),
        .immsrc(ImmSrcD),
        .immext(ImmExtD)
    );

    // Execute (EX) stage
    logic [31:0] RD1E, RD2E, PCE;
    logic [31:0] ImmExtE;
    logic [31:0] PCPlus4E;

    logic [31:0] SrcAE, SrcBE;
    logic [31:0] WriteDataE;
    logic [31:0] SrcAE_input1;
    logic [31:0] ALUResultE;

    logic RegWriteE;
    logic [1:0] ResultSrcE;
    logic MemWriteE, JumpE, BranchE;
    logic [3:0] ALUControlE;
    logic ALUSrcE;
    logic SrcAsrcE;
    logic [2:0] funct3E;
    logic branchTakenE;
    logic jumpRegE;
    logic is_ME;

    IDEXregister idexreg(
        .clk(clk), .clr(FlushE | clr),
        // ID stage control signals
        .RegWriteD(RegWriteD),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .ALUControlD(ALUControlD),
        .ALUSrcD(ALUSrcD),
        .SrcAsrcD(SrcAsrcD),
        .funct3D(funct3D),
        .jumpRegD(jumpRegD),
        .is_M(is_M),

        // EX stage control signals
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .JumpE(JumpE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE),
        .SrcAsrcE(SrcAsrcE),
        .funct3E(funct3E),
        .jumpRegE(jumpRegE),
        .is_ME(is_ME),

        // datapath inputs & outputs
        .RD1(RD1), .RD2(RD2), .PCD(PCD),
        .Rs1D(Rs1D_int), .Rs2D(Rs2D_int), .RdD(RdD),
        .ImmExtD(ImmExtD),
        .PCPlus4D(PCPlus4D),

        .RD1E(RD1E), .RD2E(RD2E), .PCE(PCE),
        .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE),
        .ImmExtE(ImmExtE),
        .PCPlus4E(PCPlus4E)
    );

    assign PCSrcE_int = (BranchE & branchTakenE) | JumpE;
    assign ResultSrcE_zero = ResultSrcE[0];
	 
	logic [31:0] ALUResultM_int;
    assign ALUResultM_int = ALUResultM;

    mux3 SrcAE_input1mux(
        .d0(RD1E), .d1(ResultW), .d2(ALUResultM_int), // inputs
        .s(ForwardAE), // select signal
        .y(SrcAE_input1) // output
    );

    mux2 SrcAEmux(
        .d0(PCE), .d1(SrcAE_input1),
        .s(SrcAsrcE), // new control signal that chooses either PC or RD1
        .y(SrcAE)
    );

    mux3 WriteDataEmux(
        .d0(RD2E), .d1(ResultW), .d2(ALUResultM_int),
        .s(ForwardBE),
        .y(WriteDataE)
    );

    mux2 SrcBEmux(
        .d0(WriteDataE), .d1(ImmExtE), // inputs
        .s(ALUSrcE), // select signal
        .y(SrcBE) // output
    );

    branch_unit bu(
        .SrcAE(SrcAE), .SrcBE(SrcBE),
        .funct3E(funct3E),
        .branchTakenE(branchTakenE)
    );

    logic [31:0] adder_base;
    assign adder_base = jumpRegE ? SrcAE_input1 : PCE;

    adder add(
        .a(adder_base), .b(ImmExtE), // inputs
        .y(PCTargetE) // output
    );

    alu alu(
        .d0(SrcAE), .d1(SrcBE), //  inputs
        .s(ALUControlE), // operation control signal
        .y(ALUResultE) // output
    );

    // Intermediate stage (to perform multiplication)
    logic RegWrite_interm;
    logic [1:0] ResultSrc_interm;
    logic MemWrite_interm;
    logic [2:0] funct3_interm;
    logic is_M_interm;
    
    logic [31:0] ALUResult_interm;
    logic [31:0] WriteData_interm;
    logic [4:0] Rd_interm;
    logic [31:0] ImmExt_interm;
    logic [31:0] PCPlus4_interm;
    logic [31:0] SrcA_interm, SrcB_interm;

    Intemediate_register interm_reg (
        // EX state control signals
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .funct3E(funct3E),
        .is_ME(is_ME),
        
        // Intermediate stage control signals
        .RegWrite_interm(RegWrite_interm),
        .ResultSrc_interm(ResultSrc_interm),
        .MemWrite_interm(MemWrite_interm),
        .funct3_interm(funct3_interm),
        .is_M_interm(is_M_interm),

        // datapath inputs & outputs
        .ALUResultE(ALUResultE),
        .WriteDataE(WriteDataE),
        .RdE(RdE),
        .ImmExtE(ImmExtE),
        .PCPlus4E(PCPlus4E),
        .SrcAE(SrcAE),
        .SrcBE(SrcBE),

        .ALUResult_interm(ALUResult_interm),
        .WriteData_interm(WriteData_interm),
        .Rd_interm(Rd_interm),
        .ImmExt_interm(ImmExt_interm),
        .PCPlus4_interm(PCPlus4_interm),
        .SrcA_interm(SrcA_interm),
        .SrcB_interm(SrcB_interm)
    );

    logic [63:0] mul_interm, mul_s_interm;

    multiplier multiplier (
        .dataa(SrcA_interm),
        .datab(SrcB_interm),
        .result(mul_interm)
    );

    multiplier_s multiplier_s (
        .dataa(SrcA_interm),
        .datab(SrcB_interm),
        .result(mul_s_interm)
    );

    // Memory write (MEM) stage
    logic [31:0] PCPlus4M;
    logic [2:0] funct3M;

    logic RegWriteM_int;
    assign RegWriteM = RegWriteM_int;
    
    logic [1:0] ResultSrcM;

    logic [1:0] byteAddrM;
    assign byteAddrM = ALUResultM_int[1:0];

    logic [31:0] load_data;
    logic [31:0] ImmExtM;

    logic is_MM;
    logic [63:0] mulM, mul_sM;
    logic [31:0] mul_resultM;
    logic SrcA_b31M;
    logic [31:0] SrcBM;

    IntermMEMregister interm_memreg(
        .clk(clk), .clr(clr),
        // Intermediate stage control signals
        .RegWrite_interm(RegWrite_interm),
        .ResultSrc_interm(ResultSrc_interm),
        .MemWrite_interm(MemWrite_interm),
        .funct3_interm(funct3_interm),
        .is_M_interm(is_M_interm),

        // MEM stage control signals
        .RegWriteM(RegWriteM_int),
        .ResultSrcM(ResultSrcM),
        .MemWriteM(MemWriteM),
        .funct3M(funct3M),
        .is_MM(is_MM),

        // datapath inputs & outputs
        .ALUResult_interm(ALUResult_interm),
        .WriteData_interm(WriteData_interm),
        .Rd_interm(Rd_interm),
        .ImmExt_interm(ImmExt_interm),
        .PCPlus4_interm(PCPlus4_interm),
        .mul_interm(mul_interm),
        .mul_s_interm(mul_s_interm),
        .SrcA_b31_interm(SrcA_interm[31]),
        .SrcB_interm(SrcB_interm),

        .ALUResultM(ALUResultM), // output to Data Memory
        .WriteDataM(WriteDataM),
        .RdM(RdM),
        .ImmExtM(ImmExtM),
        .PCPlus4M(PCPlus4M),
        .mulM(mulM),
        .mul_sM(mul_sM),
        .SrcA_b31M(SrcA_b31M),
        .SrcBM(SrcBM)
    );

    always_comb begin
        byteEnable = 4'b0000;
        case (funct3M) // funct3 determines store type
            3'b000: case (byteAddrM)
                2'b00: byteEnable = 4'b0001; // enable byte 0
                2'b01: byteEnable = 4'b0010; // enable byte 1
                2'b10: byteEnable = 4'b0100; // enable byte 2
                2'b11: byteEnable = 4'b1000; // enable byte 3
                default: byteEnable = 4'b0000;
            endcase
            3'b001: byteEnable = (byteAddrM[1] == 0) // sh
                                    ? 4'b0011 // low half
                                    : 4'b1100; // high half
            3'b010: byteEnable = 4'b1111;
            default: byteEnable = 4'b0000;
        endcase
    end

    loadext loadext(
        .LoadTypeM(funct3M),
        .RD_data(RD_data),
        .byteAddrM(byteAddrM),
        .load_data(load_data)
    );

    always_comb begin
        if (is_MM) begin
            case (funct3M)
                3'b000: mul_resultM = mulM[31:0]; // low unsigned x signed
                3'b001: mul_resultM = mul_sM[63:32]; // high signed x signed
                3'b010: mul_resultM = mulM[63:32] - (SrcA_b31M ? SrcBM : 32'b0); // high signed x unsigned
                3'b011: mul_resultM = mulM[63:32]; // high unsigned x unsigned
                default: mul_resultM = 32'b0;
            endcase
        end else mul_resultM = 32'b0;
    end // moved the select logic for multiplication results to MEM stage because it can run in parallel with other blocks in the stage.

    // -------------------------------------------------------------//
    // Register file writeback (WB) stage
    logic [31:0] ALUResultW;
    logic [31:0] ReadDataW;
    logic [31:0] PCPlus4W;
    logic [31:0] ImmExtW;
    logic [1:0] ResultSrcW;

    logic [31:0] mul_resultW;

    MEMWBregister wbreg(
        .clk(clk), .clr(clr),
        // MEM stage control signals
        .RegWriteM(RegWriteM_int),
        .ResultSrcM(ResultSrcM),

        // WB stage control signals
        .RegWriteW(RegWriteW_int),
        .ResultSrcW(ResultSrcW),

        // datapath inputs & outputs
        .ALUResultM(ALUResultM_int),
        .load_data(load_data),
        .RdM(RdM),
        .ImmExtM(ImmExtM),
        .PCPlus4M(PCPlus4M),
        .mul_resultM(mul_resultM),

        .ALUResultW(ALUResultW),
        .ReadDataW(ReadDataW),
        .RdW(RdW),
        .ImmExtW(ImmExtW),
        .PCPlus4W(PCPlus4W),
        .mul_resultW(mul_resultW)
    );

    mux4 ResultWmux(
        .d0(ALUResultW),
        .d1(ReadDataW),
        .d2(PCPlus4W),
        .d3(ImmExtW),
        .s(ResultSrcW),
        .y(ResultW)
    );

endmodule