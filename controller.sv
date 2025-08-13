module controller (input logic [6:0] op,
                   input logic [2:0] funct3,
                   input logic [6:0] funct7,

                   output logic RegWriteD,
                   output logic [1:0] ResultSrcD,
                   output logic MemWriteD,
                   output logic JumpD,
                   output logic BranchD,
                   output logic [3:0] ALUControlD,
                   output logic ALUSrcD,
                   output logic [2:0] ImmSrcD,
                   output logic SrcAsrcD,
                   output logic [2:0] funct3D,
                   output logic jumpRegD);

    logic [1:0] ALUOp;
    assign funct3D = funct3;

    maindec md(
        .op(op),
        .funct3(funct3),
        .funct7(funct7),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .BranchD(BranchD),
        .ALUSrcD(ALUSrcD),
        .RegWriteD(RegWriteD),
        .JumpD(JumpD),
        .ImmSrcD(ImmSrcD),
        .ALUOp(ALUOp),
        .SrcAsrcD(SrcAsrcD),
        .jumpRegD(jumpRegD)
    );

    aludec ad(
        .opb5(op[5]),
        .funct3(funct3),
        .funct7b5(funct7[5]),
        .ALUOp(ALUOp),
        .ALUControl(ALUControlD)
    );
    
endmodule
