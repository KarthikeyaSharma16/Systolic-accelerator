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
    logic en;
    logic [2:0] counter;

    //pipeline latch
    logic [31:0] mult_latch;

    fp_mult uut_1(clk, rst, en, PE_in_a, PE_in_b, mult_out);

    always@(posedge clk or negedge rst) begin
        if (!rst) begin
            mult_latch <= 32'b0;
        end 
        else begin
            mult_latch <= mult_out;
        end   
    end

    fp_add uut_2(clk, rst, en, accumulated_value, mult_latch, add_out);
    
    always@(posedge clk or negedge rst) begin
        if (!rst) begin
            accumulated_value <= 0;
            en <= 1;
            counter <= 0;
        end
        else begin
            if (counter == 3'b101) begin
                accumulated_value <= add_out;
                counter <= 0;
                en <= 1;
            end
            else begin
                en <= 0;
                counter <= counter + 1;
            end
        end
    end

    assign PE_out_r = accumulated_value;

endmodule