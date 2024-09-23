`timescale 1ns/1ps

module PE (
    input clk,
    input rst,
    input logic [31:0] PE_in_a,
    input logic [31:0] PE_in_b,
    output logic [31:0] PE_out_r
);
    
    logic [31:0] accumulated_value;
    logic [31:0] mult_out;
    logic [31:0] add_out;

    always@(posedge clk or negedge rst) begin
        if (!rst) begin
            accumulated_value <= 0;
        end
        else begin
            accumulated_value <= add_out;
        end
    end

    fp_mult uut_1(clk, rst, PE_in_a, PE_in_b, mult_out);
    fp_add uut_2(clk, rst, accumulated_value, mult_out, add_out);

    assign PE_out_r = accumulated_value;

endmodule