module dmem (input logic clk, we,
             input logic [3:0] byteEnable,
             input logic [31:0] a, wd,
             output logic [31:0] rd);

    logic [31:0] RAM[63:0];

    initial $readmemh("C:/intelFPGA_lite/rv32i/dmem.txt", RAM, 0, 1);

    always_ff @(posedge clk) begin

        rd <= RAM[a[31:2]]; // word-aligned

        if (we) begin
            for (int i = 0; i < 4; i++) begin
                if (byteEnable[i])
                    RAM[a[31:2]][i*8 +: 8] <= wd[i*8 +: 8];
            end
        end
    end
endmodule // Data memory