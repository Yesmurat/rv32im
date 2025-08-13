module IFregister (input logic clk, en, clr,
                    input logic [31:0] d,
                    output logic [31:0] q);
    
    always_ff @(posedge clk or posedge clr)
        if (clr) begin
            q <= 32'b0;
        end
        else if (en) q <= d;
        else q <= 32'bx;
endmodule // IF stage register

module IFIDregister (input logic clk, clr, en,
                    input logic [31:0] RD_instr, PCF, PCPlus4F,
                    output logic [31:0] InstrD, PCD, PCPlus4D);
    
    always_ff @(posedge clk or posedge clr)
        if (clr) begin
            InstrD <= 32'b0;
            PCD <= 32'b0;
            PCPlus4D <= 32'b0;
        end
        else if (en) begin
            InstrD <= RD_instr;
            PCD <= PCF;
            PCPlus4D <= PCPlus4F;
        end
endmodule // ID stage register

module IDEXregister (input logic clk, clr,

                    // ID stage controls signals
                    input logic RegWriteD,
                    input logic [1:0] ResultSrcD,
                    input logic MemWriteD,
                    input logic JumpD,
                    input logic BranchD,
                    input logic [3:0] ALUControlD,
                    input logic ALUSrcD,
                    input logic SrcAsrcD,
                    input logic [2:0] funct3D,
                    input logic jumpRegD,
                    input logic is_M,

                    // EX stage control signals
                    output logic RegWriteE,
                    output logic [1:0] ResultSrcE,
                    output logic MemWriteE,
                    output logic JumpE,
                    output logic BranchE,
                    output logic [3:0] ALUControlE,
                    output logic ALUSrcE,
                    output logic SrcAsrcE,
                    output logic [2:0] funct3E,
                    output logic jumpRegE,
                    output logic is_ME,

                    // Datapath inputs & outputs
                    input logic [31:0] RD1, RD2, PCD,
                    input logic [4:0] Rs1D, Rs2D, RdD,
                    input logic [31:0] ImmExtD,
                    input logic [31:0] PCPlus4D,

                    output logic [31:0] RD1E, RD2E, PCE,
                    output logic [4:0] Rs1E, Rs2E, RdE,
                    output logic [31:0] ImmExtE,
                    output logic [31:0] PCPlus4E
);

    always_ff @(posedge clk or posedge clr) begin
        if (clr) begin

            RegWriteE <= 1'b0;
            ResultSrcE <= 2'b0;
            MemWriteE <= 1'b0;
            JumpE <= 1'b0;
            BranchE <= 1'b0;
            ALUControlE <= 4'b0;
            ALUSrcE <= 1'b0;
            SrcAsrcE <= 1'b0;
            funct3E <= 3'b0;
            jumpRegE <= 1'b0;
            is_ME <= 1'b0;

            RD1E <= 32'b0; RD2E <= 32'b0; PCE <= 32'b0;
            Rs1E <= 5'b0; Rs2E <= 5'b0; RdE <= 5'b0;
            ImmExtE <= 32'b0;
            PCPlus4E <= 32'b0;
        end else begin

            RegWriteE <= RegWriteD;
            ResultSrcE <= ResultSrcD;
            MemWriteE <= MemWriteD;
            JumpE <= JumpD;
            BranchE <= BranchD;
            ALUControlE <= ALUControlD;
            ALUSrcE <= ALUSrcD;
            SrcAsrcE <= SrcAsrcD;
            funct3E <= funct3D;
            jumpRegE <= jumpRegD;
            is_ME <= is_M;

            RD1E <= RD1; RD2E <= RD2; PCE <= PCD;
            Rs1E <= Rs1D; Rs2E <= Rs2D; RdE <= RdD;
            ImmExtE <= ImmExtD;
            PCPlus4E <= PCPlus4D;
        end
    end   
endmodule

module Intemediate_register (input logic clk,
                    
                    // EX stage control signals
                    input logic RegWriteE,
                    input logic [1:0] ResultSrcE,
                    input logic MemWriteE,
                    input logic [2:0] funct3E,
                    input logic is_ME,

                    // Intermediate stage control signals
                    output logic RegWrite_interm,
                    output logic [1:0] ResultSrc_interm,
                    output logic MemWrite_interm,
                    output logic [2:0] funct3_interm,
                    output logic is_M_interm,

                    // datapath inputs & outputs
                    input logic [31:0] ALUResultE,
                    input logic [31:0] WriteDataE,
                    input logic [4:0] RdE,
                    input logic [31:0] ImmExtE,
                    input logic [31:0] PCPlus4E,
                    input logic [31:0] SrcAE,
                    input logic [31:0] SrcBE,

                    output logic [31:0] ALUResult_interm,
                    output logic [31:0] WriteData_interm,
                    output logic [4:0] Rd_interm,
                    output logic [31:0] ImmExt_interm,
                    output logic [31:0] PCPlus4_interm,
                    output logic [31:0] SrcA_interm,
                    output logic [31:0] SrcB_interm
);

    always_ff @(posedge clk or posedge clr) begin

        if (clr) begin
            RegWrite_interm <= 1'b0;
            ResultSrc_interm <= 2'b0;
            MemWrite_interm <= 1'b0;
            funct3_interm <= 3'b0;
            is_M_interm <= 1'b0;

            ALUResult_interm <= 32'b0;
            WriteData_interm <= 32'b0;
            Rd_interm <= 5'b0;
            ImmExt_interm <= 32'b0;
            PCPlus4_interm <= 32'b0;
            SrcA_interm <= 32'b0;
            SrcB_interm <= 32'b0;
        end else begin
            RegWrite_interm <= RegWriteE;
            ResultSrc_interm <= ResultSrcE;
            MemWrite_interm <= MemWriteE;
            funct3_interm <= funct3E;
            is_M_interm <= is_ME;

            ALUResult_interm <= ALUResultE;
            WriteData_interm <= WriteDataE;
            Rd_interm <= RdE;
            ImmExt_interm <= ImmExtE;
            PCPlus4_interm <= PCPlus4E;
            SrcA_interm <= SrcAE;
            SrcB_interm <= SrcBE;
        end
    end  
    
endmodule

module IntermMEMregister (input logic clk, clr, // Interm -> MEM

                    // Intermediate stage control signals
                    input logic RegWrite_interm,
                    input logic [1:0] ResultSrc_interm,
                    input logic MemWrite_interm,
                    input logic [2:0] funct3_interm,

                    // MEM stage control signals
                    output logic RegWriteM,
                    output logic [1:0] ResultSrcM,
                    output logic MemWriteM,
                    output logic [2:0] funct3M,

                    // datapath inputs & outputs
                    input logic [31:0] ALUResult_interm,
                    input logic [31:0] WriteData_interm,
                    input logic [4:0] Rd_interm,
                    input logic [31:0] ImmExt_interm,
                    input logic [31:0] PCPlus4_interm,
                    input logic [63:0] mul_interm,
                    input logic [63:0] mul_s_interm,

                    output logic [31:0] ALUResultM,
                    output logic [31:0] WriteDataM,
                    output logic [4:0] RdM,
                    output logic [31:0] ImmExtM,
                    output logic [31:0] PCPlus4M,
                    output logic [63:0] mulM,
                    output logic [63:0] mul_sM
);

    always_ff @(posedge clk or posedge clr) begin

        if (clr) begin
            RegWriteM <= 1'b0;
            ResultSrcM <= 2'b0;
            MemWriteM <= 1'b0;
            funct3M <= 3'b0;

            ALUResultM <= 32'b0;
            WriteDataM <= 32'b0;
            RdM <= 5'b0;
            ImmExtM <= 32'b0;
            PCPlus4M <= 32'b0;
        end else begin
            RegWriteM <= RegWrite_interm;
            ResultSrcM <= ResultSrc_interm;
            MemWriteM <= MemWrite_interm;
            funct3M <= funct3_interm;

            ALUResultM <= ALUResult_interm;
            WriteDataM <= WriteData_interm;
            RdM <= Rd_interm;
            ImmExtM <= ImmExt_interm;
            PCPlus4M <= PCPlus4_interm;
        end
    end  
endmodule

module MEMWBregister (input logic clk, clr, // MEM -> WB

                    // MEM stage control signals
                    input logic RegWriteM,
                    input logic [1:0] ResultSrcM,

                    // WB stage signals
                    output logic RegWriteW,
                    output logic [1:0] ResultSrcW,

                    // datapath inputs & outputs
                    input logic [31:0] ALUResultM,
                    input logic [31:0] load_data,
                    input logic [4:0] RdM,
                    input logic [31:0] ImmExtM,
                    input logic [31:0] PCPlus4M,

                    output logic [31:0] ALUResultW,
                    output logic [31:0] ReadDataW,
                    output logic [4:0] RdW,
                    output logic [31:0] ImmExtW,
                    output logic [31:0] PCPlus4W
);

    always_ff @(posedge clk or posedge clr) begin
        if (clr) begin
            RegWriteW <= 1'b0;
            ResultSrcW <= 2'b0;

            ALUResultW <= 32'b0;
            ReadDataW <= 32'b0;
            RdW <= 5'b0;
            ImmExtW <= 32'b0;
            PCPlus4W <= 32'b0;
        end else begin
            RegWriteW <= RegWriteM;
            ResultSrcW <= ResultSrcM;

            ALUResultW <= ALUResultM;
            ReadDataW <= load_data;
            RdW <= RdM;
            ImmExtW <= ImmExtM;
            PCPlus4W <= PCPlus4M;
        end
    end   
endmodule