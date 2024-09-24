`timescale 1ns/1ps

module tb_fp_add;
  logic [31:0] fp_add_a, fp_add_b;
  logic [31:0] fp_add_r;
  logic clk;
  logic rst;

  fp_add uut(clk, rst, fp_add_a, fp_add_b, fp_add_r);

  // Clock generation
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end

  initial begin
    rst = 1;
    #20;
    rst = 0;
    #20;
    rst = 1;
  end

  initial begin
    $monitor("Time = %0t | clk = %b | rst = %0b | fp_add_a = %0x, fp_add_b = %0x, fp_add_r = %0x", $time, clk, rst, fp_add_a, fp_add_b, fp_add_r);
  end

  // Apply inputs
  initial begin
    fp_add_a = 32'b0; fp_add_b = 32'b0;
    repeat(5) @(posedge clk);
    
    @(posedge clk);
    fp_add_a = 32'h40000000; fp_add_b = 32'h41000000;

    @(posedge clk);
    fp_add_a = 32'h40800000; fp_add_b = 32'h40000000;

    @(posedge clk);
    fp_add_a = 32'h41000000; fp_add_b = 32'h41000000;

    @(posedge clk);
    fp_add_a = 32'h41800000; fp_add_b = 32'h0;

    #150;
    $finish();
  end

  // Dump signals for waveform viewing
  initial begin
    $dumpfile("outputs/waveform.vcd");
    $dumpvars;
  end

endmodule
