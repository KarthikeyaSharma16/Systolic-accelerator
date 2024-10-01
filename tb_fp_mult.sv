`timescale 1ns/1ps

module tb_fp_mult;
  logic [31:0] in_a, in_b;
  logic [31:0] out_r;
  logic clk;
  logic rst;
  logic en;
  logic ready;

  fp_mult uut(clk, rst, en, in_a, in_b, out_r, ready);

  // Clock generation
  initial begin
      rst = 0;
      #20;
      rst = 1;
  end

  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end

  initial begin
    $monitor("Time = %0t | clk = %b | in_a = %0x, in_b = %0x, out_r = %0x", $time, clk, in_a, in_b, out_r);
  end

  // Apply inputs
  initial begin
    in_a = 32'b0; in_b = 32'b0;

    @(posedge clk);
    in_a = 32'h40000000; in_b = 32'h40000000;

    @(posedge clk);
    in_a = 32'h40800000; in_b = 32'h40800000;

    @(posedge clk);
    in_a = 32'h41000000; in_b = 32'h41000000;

    @(posedge clk);
    in_a = 32'h41800000; in_b = 32'h41800000;

    #100;
    $finish();
  end

  // Dump signals for waveform viewing
  initial begin
    $dumpfile("outputs/waveform.vcd");
    $dumpvars;
  end

endmodule