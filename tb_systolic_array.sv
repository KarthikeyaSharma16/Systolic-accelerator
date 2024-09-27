`timescale 1ns/1ps

module tb_systolic_array;
  logic [31:0] sys_a [3:0], sys_b [3:0];
  logic [31:0] sys_r [15:0];
  logic clk;
  logic rst;

  systolic_array uut(clk, rst, sys_a, sys_b, sys_r);

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
      $monitor("Time = %0t | clk = %b | rst = %0b | sys_a[%0d] = %0x, sys_b[%0d] = %0x | sys_a[%0d] = %0x, sys_b[%0d] = %0x | sys_a[%0d] = %0x, sys_b[%0d] = %0x | sys_a[%0d] = %0x, sys_b[%0d] = %0x \nsys_r[%0d] = %0x \nsys_r[%0d] = %0x \nsys_r[%0d] = %0x \nsys_r[%0d] = %0x \nsys_r[%0d] = %0x \nsys_r[%0d] = %0x \nsys_r[%0d] = %0x \nsys_r[%0d] = %0x \nsys_r[%0d] = %0x \nsys_r[%0d] = %0x \nsys_r[%0d] = %0x \nsys_r[%0d] = %0x \nsys_r[%0d] = %0x \nsys_r[%0d] = %0x \nsys_r[%0d] = %0x \nsys_r[%0d] = %0x \n\n", $time, clk, rst, 0, sys_a[0], 0, sys_b[0], 1, sys_a[1], 1, sys_b[1], 2, sys_a[2], 2, sys_b[2], 3, sys_a[3], 3, sys_b[3], 0, sys_r[0], 1, sys_r[1], 2, sys_r[2], 3, sys_b[3], 4, sys_a[4], 5, sys_b[5], 6, sys_a[6], 7, sys_b[7], 8, sys_r[8], 9, sys_r[9], 10, sys_r[10], 11, sys_b[11], 12, sys_a[12], 13, sys_b[13], 14, sys_a[14], 15, sys_b[15]);
  end

  // Apply inputs
  initial begin
    sys_a[0] = 32'b0; sys_b[0] = 32'b0;
    sys_a[1] = 32'b0; sys_b[1] = 32'b0;
    sys_a[2] = 32'b0; sys_b[2] = 32'b0;
    sys_a[3] = 32'b0; sys_b[3] = 32'b0;
    repeat(10) @(posedge clk);
    
    repeat(10) @(posedge clk);
    sys_a[0] = 32'b01000000000000000000000000000000; sys_b[0] = 32'h41000000;
    sys_a[1] = 32'b01000000000000000000000000000000; sys_b[1] = 32'h41000000;
    sys_a[2] = 32'b01000000000000000000000000000000; sys_b[2] = 32'h41000000;
    sys_a[3] = 32'b01000000000000000000000000000000; sys_b[3] = 32'h41000000;

    repeat(10) @(posedge clk);
    sys_a[0] = 32'b01000000000000000000000000000000; sys_b[0] = 32'h41000000;
    sys_a[1] = 32'b01000000000000000000000000000000; sys_b[1] = 32'h41000000;
    sys_a[2] = 32'b01000000000000000000000000000000; sys_b[2] = 32'h41000000;
    sys_a[3] = 32'b01000000000000000000000000000000; sys_b[3] = 32'h41000000;

    repeat(10) @(posedge clk);
    sys_a[0] = 32'b01000000000000000000000000000000; sys_b[0] = 32'h41000000;
    sys_a[1] = 32'b01000000000000000000000000000000; sys_b[1] = 32'h41000000;
    sys_a[2] = 32'b01000000000000000000000000000000; sys_b[2] = 32'h41000000;
    sys_a[3] = 32'b01000000000000000000000000000000; sys_b[3] = 32'h41000000;

    repeat(10) @(posedge clk);
    sys_a[0] = 32'b01000000000000000000000000000000; sys_b[0] = 32'h41000000;
    sys_a[1] = 32'b01000000000000000000000000000000; sys_b[1] = 32'h41000000;
    sys_a[2] = 32'b01000000000000000000000000000000; sys_b[2] = 32'h41000000;
    sys_a[3] = 32'b01000000000000000000000000000000; sys_b[3] = 32'h41000000;

    #2000;
    $finish();
  end

  // Dump signals for waveform viewing
  initial begin
    $dumpfile("outputs/waveform.vcd");
    $dumpvars;
  end

endmodule
