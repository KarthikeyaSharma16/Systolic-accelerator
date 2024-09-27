`timescale 1ns/1ps

/*
    Pipelined fp_32 adder design
*/

module fp_add
(
    input logic clk,
    input logic rst,
    input logic en,
    input logic [31:0] PE_a,
    input logic [31:0] PE_b,
    output logic [31:0] PE_result
);

    //Pipeline registers
    //Stage-1
    logic sign_a_s1;
    logic [7:0] exp_a_s1;
    logic [23:0] mantissa_a_s1;
    logic sign_b_s1;
    logic [7:0] exp_b_s1;
    logic [23:0] mantissa_b_s1;
    logic larger_mantissa_s1;
    logic is_a_zero;
    logic is_b_zero;

    //Stage-2
    logic [7:0] exp_r_s2;
    logic [47:0] mantissa_r_s2;

    //Stage-3
    logic [7:0] exp_r_s3;
    logic [7:0] exp_r_s3_temp;
    logic [23:0] mantissa_r_s3;
    logic [47:0] mantissa_r_s3_temp;    

    //Stage-4
    logic sign_r_s4;
    logic [7:0] exp_r_s4;
    logic [23:0] mantissa_r_s4;

    //Pipeline stage-1 - Decode the PE_mult and the result
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
           sign_a_s1 <= 0;
           exp_a_s1 <= 0;
           mantissa_a_s1 <= 0;
           sign_b_s1 <= 0;
           exp_b_s1 <= 0;
           mantissa_b_s1 <= 0;
           larger_mantissa_s1 <= 0;
           is_a_zero <= 0;
           is_b_zero <= 0;
        end
        else begin
            if (en) begin
                sign_a_s1 <= PE_a[31];
                exp_a_s1 <= PE_a[30:23];
                mantissa_a_s1 <= {1'b1, PE_a[22:0]};
                sign_b_s1 <= PE_b[31];
                exp_b_s1 <= PE_b[30:23];
                mantissa_b_s1 <= {1'b1, PE_b[22:0]};

                is_a_zero <= (PE_a[30:23] == 8'b0 && PE_a[22:0] == 23'b0);
                is_b_zero <= (PE_b[30:23] == 8'b0 && PE_b[22:0] == 23'b0);

                // Compare original mantissas and store which one is larger
                if (exp_a_s1 > exp_b_s1 || (exp_a_s1 == exp_b_s1 && mantissa_a_s1 > mantissa_b_s1)) begin
                    larger_mantissa_s1 <= 1;
                end 
                else begin
                    larger_mantissa_s1 <= 0;
                end
            end
        end
    end

    //stage-2 : Computing the effective exponent and mantissa.
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            mantissa_r_s2 <= 0;
            exp_r_s2 <= 0;
        end
        else begin
           if (is_a_zero && is_b_zero) begin
                mantissa_r_s2 <= 0;
                exp_r_s2 <= 0;
           end
           else if (!is_a_zero && is_b_zero) begin
                mantissa_r_s2 <= mantissa_a_s1;
                exp_r_s2 <= exp_a_s1;
           end
           else if (is_a_zero && !is_b_zero) begin
                mantissa_r_s2 <= mantissa_b_s1;
                exp_r_s2 <= exp_b_s1;
           end
           else begin
                if (exp_a_s1 == exp_b_s1) begin
                    mantissa_r_s2 <= mantissa_a_s1 + mantissa_b_s1;
                    exp_r_s2 <= exp_b_s1;
                end
                else if (exp_a_s1 < exp_b_s1) begin
                    mantissa_r_s2 <= (mantissa_a_s1 >> (exp_b_s1 - exp_a_s1)) + mantissa_b_s1;
                    exp_r_s2 <= exp_b_s1;
                end 
                else begin
                    mantissa_r_s2 <= (mantissa_b_s1 >> (exp_a_s1 - exp_b_s1)) + mantissa_a_s1;
                    exp_r_s2 <= exp_a_s1;
                end
           end
        end
    end

    //Stage-3 : Normalize the result, account for Mantissa overflow too.
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            mantissa_r_s3 <= 0;
            exp_r_s3 <= 0;
        end
        else begin
            mantissa_r_s3_temp = mantissa_r_s2;
            exp_r_s3_temp = exp_r_s2;

            // Shift right to normalize mantissa
            while (mantissa_r_s3_temp[23] == 0 && exp_r_s3_temp > 0) begin
                mantissa_r_s3_temp = mantissa_r_s3_temp >> 1;
                exp_r_s3_temp = exp_r_s3_temp + 1;
            end

            mantissa_r_s3 <= mantissa_r_s3_temp[23:0];
            exp_r_s3 <= exp_r_s3_temp;
        end
    end

    //Stage-4 : Handling sign logic
    always@(posedge clk or negedge rst) begin
        if (!rst) begin
            sign_r_s4 <= 0;
            exp_r_s4 <= 0;
            mantissa_r_s4 <= 0;
        end
        else begin
            mantissa_r_s4 <= mantissa_r_s3;
            exp_r_s4 <= exp_r_s3;
            
            if (sign_a_s1 == sign_b_s1) begin
                sign_r_s4 <= sign_b_s1;
            end
            else begin
                if (larger_mantissa_s1) begin
                    sign_r_s4 <= sign_a_s1;
                end
                else begin
                    sign_r_s4 <= sign_b_s1;
                end
            end
        end
    end

    //Stage-5 : final result
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            PE_result <= 0;
        end
        else begin
            if (exp_r_s4 == 8'b0 && mantissa_r_s4 == 24'b0) begin
                if (is_a_zero && is_b_zero) begin
                    PE_result <= 32'b0;
                end
                else if (is_a_zero) begin
                    PE_result <= {sign_b_s1, 31'b0};
                end
                else if (is_b_zero) begin
                    PE_result <= {sign_a_s1, 31'b0};
                end 
            end
            else begin
                if (exp_r_s4 > 8'hFF) begin
                    PE_result <= {sign_r_s4, 8'hFF, 23'b0};
                end
                else if (exp_r_s4 < 8'h00) begin
                    PE_result <= {sign_r_s4, 8'h00, 23'b0};
                end
                else begin
                    PE_result <= {sign_r_s4, exp_r_s4[7:0], mantissa_r_s4[22:0]}; 
                end
            end
        end
    end

endmodule