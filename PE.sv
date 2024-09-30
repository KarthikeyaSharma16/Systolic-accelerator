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
    logic en_mult;
    logic en_add;
    logic ready_mult;
    logic ready_add;

    //pipeline latch
    logic [31:0] mult_latch;

    fp_mult uut_1(.clk(clk), 
                  .rst(rst), 
                  .en(en_mult), 
                  .a(PE_in_a), 
                  .b(PE_in_b), 
                  .result(mult_out),
                  .ready(ready_mult));

    always@(posedge clk or negedge rst) begin
        if (!rst) begin
            mult_latch <= 32'b0;
        end 
        else begin
            mult_latch <= mult_out;
        end   
    end

    fp_add uut_2(.clk(clk), 
                 .rst(rst), 
                 .en(en_add), 
                 .a(accumulated_value), 
                 .b(mult_latch), 
                 .sum(add_out),
                 .ready(ready_add));
    
    always@(posedge clk or negedge rst) begin
        if (!rst) begin
            accumulated_value <= 0;
            en_mult <= 1;
            en_add <= 1;
        end
        else begin
            if (ready_mult) begin
                en_mult <= 1;
            end
            else begin
               en_mult <= 0; 
            end

            if (ready_add) begin
                en_add <= 1;
                accumulated_value <= add_out;
            end
            else begin
                en_add <= 0;
            end
        end
    end

    assign PE_out_r = accumulated_value;

endmodule