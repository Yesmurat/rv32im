module imem (input logic clk,
            input logic [31:0] a,
            output logic [31:0] rd);

    logic [31:0] RAM[63:0];

    initial $readmemh("C:/intelFPGA_lite/rv32i/imem.txt", RAM, 0, 1);

    always_ff @(posedge clk) rd <= RAM[a[31:2]]; // word aligned

endmodule // Instruction memory