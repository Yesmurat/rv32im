`timescale 1ns/1ps

module top_tb;

  logic clk;
  logic clr;

  logic [31:0] RD_instr, RD_data;
  logic [31:0] PCF;
  logic [31:0] ALUResultM, WriteDataM;


  top dut(
      .clk(clk),
      .clr(clr),
      .RD_instr(RD_instr),
      .RD_data(RD_data),
      .PCF(PCF),
      .ALUResultM(ALUResultM),
      .WriteDataM(WriteDataM)
  );

  initial begin
        clr <= 1'b1; #2; clr <= 1'b0;
	    #50; $stop;
  end

    always begin
        clk <= 1'b1; #5; clk <= 1'b0; #5;
    end

endmodule