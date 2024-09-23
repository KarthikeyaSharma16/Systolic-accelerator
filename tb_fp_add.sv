`timescale 1ns/1ps

module tb_fp_add;
  logic [31:0] fp_add_a, fp_add_b;
  logic [31:0] fp_add_r;
  logic clk;
  logic rst;

  fp_add uut(clk, rst, fp_add_a, fp_add_b, fp_add_r);

  // Clock generation
  initial begin
    fp_add_a = 32'b0; fp_add_b = 32'b0;
    clk = 0;
    rst = 1; // Keep reset high initially
    #10;
    rst = 0; // Assert reset low for at least 1 cycle
    #50;
    rst = 1; // De-assert reset
  end

  always #10 clk = ~clk;

  initial begin
    $monitor("Time = %0t | clk = %b | rst = %0b | fp_add_a = %0x, fp_add_b = %0x, fp_add_r = %0x", $time, clk, rst, fp_add_a, fp_add_b, fp_add_r);
  end

  // Apply inputs
  initial begin
    #50;
    fp_add_a = 32'b0; fp_add_b = 32'b0;
    
    #20;
    fp_add_a = 32'b01000000000000000000000000000000; fp_add_b = 32'b01000000000000000000000000000000;

    #20;
    fp_add_a = 32'h40800000; fp_add_b = 32'h40800000;

    #20;
    fp_add_a = 32'h41000000; fp_add_b = 32'h41000000;

    #20;
    fp_add_a = 32'h41800000; fp_add_b = 32'h41800000;

    #100;
    $finish();
  end

  // Dump signals for waveform viewing
  initial begin
    $dumpfile("outputs/waveform.vcd");
    $dumpvars;
  end

endmodule
