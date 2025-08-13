module riscv (input logic clk, clr,
                        // inputs from Instruction and Data memories
                        input logic [31:0] RD_instr, RD_data,

                        // outputs to Instruction and Data memories
                        output logic [31:0] PCF,
                        output logic [31:0] ALUResultM, WriteDataM,
                        output logic MemWriteM,
                        output logic [3:0] byteEnable);

    // control signals
    logic RegWriteD;
    logic [1:0] ResultSrcD;
    logic MemWriteD;
    logic JumpD;
    logic BranchD;
    logic [3:0] ALUControlD;
    logic ALUSrcD;
    logic [2:0] ImmSrcD;
    logic SrcAsrcD;

    logic [31:0] InstrD;
    logic ResultSrcE_zero;

    // Hazard unit wires
    logic StallF;
    logic StallD, FlushD;
    logic FlushE;
    logic [1:0] ForwardAE, ForwardBE;
    logic PCSrcE;

    logic [4:0] Rs1D, Rs2D;
    logic [4:0] Rs1E, Rs2E, RdE;
    logic ResultSrcE;
    logic [4:0] RdM, RdW;
    logic RegWriteM, RegWriteW;

    logic [2:0] funct3;
    logic jumpRegD;
    logic [1:0] src1;

    // ----------------------------

    controller c(
        .op(InstrD[6:0]),
        .funct3(InstrD[14:12]),
        .funct7(InstrD[31:25]),
        
        .RegWriteD(RegWriteD),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .ALUControlD(ALUControlD),
        .ALUSrcD(ALUSrcD),
        .ImmSrcD(ImmSrcD),
        .SrcAsrcD(SrcAsrcD),
        .funct3D(funct3),
        .jumpRegD(jumpRegD)
    );

    datapath dp(.clk(clk), .clr(clr),

                // Control signals
                .RegWriteD(RegWriteD),
                .ResultSrcD(ResultSrcD),
                .MemWriteD(MemWriteD),
                .JumpD(JumpD),
                .BranchD(BranchD),
                .ALUControlD(ALUControlD),
                .ALUSrcD(ALUSrcD),
                .ImmSrcD(ImmSrcD),
                .SrcAsrcD(SrcAsrcD),
                .funct3D(funct3),
                .jumpRegD(jumpRegD),

                // inputs from Hazard unit
                .StallF(StallF), .StallD(StallD), .FlushD(FlushD), .FlushE(FlushE),
                .ForwardAE(ForwardAE), .ForwardBE(ForwardBE),

                .RD_instr(RD_instr), .RD_data(RD_data),

                // outputs to Instruction and Data memories
                .PCF(PCF),
                .ALUResultM(ALUResultM), .WriteDataM(WriteDataM),
				.MemWriteM(MemWriteM),
                .InstrD(InstrD),
                .byteEnable(byteEnable),

                // outputs to Hazard unit
                .Rs1D(Rs1D), .Rs2D(Rs2D),
                .Rs1E(Rs1E), .Rs2E(Rs2E),
                .PCSrcE(PCSrcE), .ResultSrcE_zero(ResultSrcE_zero),
                .RegWriteM(RegWriteM), .RegWriteW(RegWriteW),
                .RdE(RdE),
                .RdM(RdM),
                .RdW(RdW));

    hazard hu(
        .Rs1D(Rs1D), .Rs2D(Rs2D),
        .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE),
        .PCSrcE(PCSrcE),
        .ResultSrcE_zero(ResultSrcE_zero),
        .RdM(RdM),
        .RegWriteM(RegWriteM),
        .RdW(RdW),
        .RegWriteW(RegWriteW),

        .StallF(StallF),
        .StallD(StallD), .FlushD(FlushD),
        .FlushE(FlushE),
        .ForwardAE(ForwardAE), .ForwardBE(ForwardBE)
    );
    
endmodule