`timescale 1ns/1ps

/*
    Pipelined fp_32 multiplier design
*/

module fp_mult (
    input logic clk,
    input logic rst,
    input logic en,
    input logic [31:0] a,
    input logic [31:0] b,
    output logic [31:0] result //fp_32 result
);

    //Declaring pipeline stages registers
    //Stage-1 registers/latches
    logic sign_a_s1, sign_b_s1;
    logic [7:0] exp_a_s1, exp_b_s1;
    logic [23:0] mantissa_a_s1, mantissa_b_s1;

    //Stage-2 registers/latches
    logic [47:0] mantissa_r_s2;
    logic [7:0] exp_r_s2;
    logic sign_s2;
    
    //Stage-3 registers/latches
    logic [23:0] mantissa_r_s3;
    logic [7:0] exp_r_s3;
    logic sign_s3;

    //PIPELINE STAGE 1: Decode inputs
    always@(posedge clk or negedge rst) begin
        if (!rst) begin
            sign_a_s1 <= 0;
            sign_b_s1 <= 0;
            exp_a_s1 <= 8'b0;
            exp_b_s1 <= 8'b0;
            mantissa_a_s1 <= 24'b0;
            mantissa_b_s1 <= 24'b0;
        end
        else begin
            sign_a_s1 <= a[31];
            sign_b_s1 <= b[31];
            exp_a_s1 <= a[30:23];
            exp_b_s1 <= b[30:23];
            mantissa_a_s1 <= {1'b1, a[22:0]};
            mantissa_b_s1 <= {1'b1, b[22:0]};
        end
    end
    
    //PIPELINE STAGE 2: Multiply mantissas
    always@(posedge clk or negedge rst) begin
        if (!rst) begin
            mantissa_r_s2 <= 48'b0;
            exp_r_s2 <= 8'b0;
            sign_s2 <= 0;
        end
        else begin
            if ((exp_a_s1 == 8'b0 && mantissa_a_s1[22:0] == 23'b0) || exp_b_s1 == 8'b0 && mantissa_b_s1[22:0] == 23'b0) begin
                mantissa_r_s2 <= 0;
                exp_r_s2 <= 0;
                sign_s2 <= 0; 
            end
            else begin
                mantissa_r_s2 <= mantissa_a_s1 * mantissa_b_s1;
                exp_r_s2 <= exp_a_s1 + exp_b_s1 - 127;
                sign_s2 <= sign_a_s1 ^ sign_b_s1;
            end
        end
    end

    //PIPELINE STAGE 3: Normalize and make adjustments to the mantissa obtained.
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            mantissa_r_s3 <= 0;
            exp_r_s3 <= 0;
            sign_s3 <= 0;
        end
        else begin
            if (mantissa_r_s2[47] == 1'b1) begin
                mantissa_r_s3 <= mantissa_r_s2[46:24];
                exp_r_s3 <= exp_r_s2 + 1;
                sign_s3 <= sign_s2;
            end
            else begin
                mantissa_r_s3 <= mantissa_r_s2[45:23];
                exp_r_s3 <= exp_r_s2;
                sign_s3 <= sign_s2;
            end
        end
    end

    //PIPELINE STAGE 4: Final result.
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            result <= 32'b0;
        end
        else begin
            if (en) begin
                //Overflow, underflow conditions
                if (exp_r_s3 >= 8'hFF) begin
                    result <= {sign_s3, 8'hFF, 23'b0};
                end
                else if (exp_r_s3 <= 8'h00) begin
                    result <= {sign_s3, 8'h00, 23'b0};
                end
                else begin
                    result <= {sign_s3, exp_r_s3[7:0], mantissa_r_s3[22:0]};
                end
            end 
        end
    end
    
endmodule