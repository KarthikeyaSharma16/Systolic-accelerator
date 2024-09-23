`timescale 1ns/1ps

module tb_fp_mult;
  logic [31:0] in_a, in_b;
  logic [31:0] out_r;
  logic clk;
  logic rst;

  fp_mult uut(clk, rst, in_a, in_b, out_r);

  // Clock generation
  initial begin
      in_a = 32'b00000000000000000000000000000000; in_b = 32'b00000000000000000000000000000000;
      clk = 0;
      rst = 1; // Keep reset high initially
      #20;
      rst = 0; // Assert reset low for at least 1 cycle
      #20;
      rst = 1; // De-assert reset
  end


  always #10 clk = ~clk;

  initial begin
    $monitor("Time = %0t | clk = %b | in_a = %0x, in_b = %0x, out_r = %0x", $time, clk, in_a, in_b, out_r);
  end

  // Apply inputs
  initial begin

    #50;
    in_a = 32'b01000000000000000000000000000000; in_b = 32'b01000000000000000000000000000000;

    #20;
    in_a = 32'b01000000100000000000000000000000; in_b = 32'b01000000100000000000000000000000;

    #20;
    in_a = 32'b01000001000000000000000000000000; in_b = 32'b01000001000000000000000000000000;

    #20;
    in_a = 32'b01000001100000000000000000000000; in_b = 32'b01000001100000000000000000000000;

    #20;
    in_a = 32'b01000010100000000000000000000000; in_b = 32'b01000010100000000000000000000000;

    #100;
    $finish();
  end

  // Dump signals for waveform viewing
  initial begin
    $dumpfile("outputs/waveform.vcd");
    $dumpvars;
  end

endmodule
