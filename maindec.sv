module maindec (input logic [6:0] op,
                input logic [2:0] funct3,
                input logic [6:0] funct7,
                output logic [2:0] ResultSrcD,
                output logic MemWriteD,
                output logic BranchD, ALUSrcD,
                output logic RegWriteD, JumpD,
                output logic [2:0] ImmSrcD,
                output logic [1:0] ALUOp,
                output logic SrcAsrcD,
                output logic jumpRegD,
                output logic is_M);

    logic [14:0] controls;

    assign {RegWriteD, ImmSrcD, ALUSrcD, MemWriteD,
            ResultSrcD, BranchD, ALUOp, JumpD, SrcAsrcD, jumpRegD} = controls;

    always_comb begin
        is_M = 1'b0;

        case (op)
            // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump_SrcAsrc_jumpReg
            7'b0110011: begin
                if (funct7 == 7'b0000001) begin
                    controls = 15'b1_xxx_0_0_100_0_xx_0_1_0; // M-instructions
                    is_M = 1'b1;
                end else controls = 15'b1_000_0_0_000_0_10_0_1_0; // R-type
            end
            7'b0000011: controls = 15'b1_000_1_0_001_0_00_0_1_0; // I-type (loads)

            7'b0100011: controls = 15'b0_001_1_1_xxx_0_00_0_1_0; // S-type

            7'b0010011: controls = 15'b1_000_1_0_000_0_10_0_1_0; // I-type

            7'b1100011: controls = 15'b0_010_0_0_000_1_01_0_1_0; // B-type

            7'b0110111: controls = 15'b1_100_1_0_011_0_00_0_x_0; // lui

            7'b0010111: controls = 15'b1_100_1_0_000_0_00_0_0_0; // auipc

            7'b1101111: controls = 15'b1_011_x_0_010_0_xx_1_1_0; // jal

            7'b1100111: controls = 15'b1_000_x_0_010_0_xx_1_1_1; // jalr

            default: controls = 15'b0; // undefined
        endcase
    end
    
endmodule