`timescale 1ns/1ps

module tb_PE;
  logic [31:0] PE_a, PE_b;
  logic [31:0] PE_r;
  logic clk;
  logic rst;

  PE uut(clk, rst, PE_a, PE_b, PE_r);

  // Clock generation
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end

  initial begin
    rst = 0;
    #20;
    rst = 1;
  end

  initial begin
    $monitor("Time = %0t | clk = %b | rst = %0b | PE_a = %0x, PE_b = %0x, PE_r = %0x", $time, clk, rst, PE_a, PE_b, PE_r);
  end

  // Apply inputs
  initial begin
    PE_a = 32'b0; PE_b = 32'b0;
    repeat(5) @(posedge clk);
    
    repeat(5) @(posedge clk);
    PE_a = 32'b01000000000000000000000000000000; PE_b = 32'h41000000;

    repeat(5) @(posedge clk);
    PE_a = 32'h40800000; PE_b = 32'h41000000;

    repeat(5) @(posedge clk);
    PE_a = 32'h41000000; PE_b = 32'h41000000;

    repeat(5) @(posedge clk);
    PE_a = 32'h41800000; PE_b = 32'h41000000;

    #400;
    $finish();
  end

  // Dump signals for waveform viewing
  initial begin
    $dumpfile("outputs/waveform.vcd");
    $dumpvars;
  end

endmodule
