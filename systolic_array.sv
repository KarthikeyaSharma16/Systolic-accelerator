`timescale 1ns/1ps

module systolic_array (
    input clk,
    input rst,
    input logic [31:0] matrix_A [3:0], 
    input logic [31:0] matrix_B [3:0],
    output logic [31:0] matrix_C [15:0]
);

    logic [31:0] matrix_A_reg [3:0];
    logic [31:0] matrix_B_reg [3:0];
    logic [31:0] matrix_C_reg [15:0];

    always@(posedge clk or negedge rst) begin
        if (!rst) begin
           for (int i = 0; i < 4; i++) begin
                matrix_A_reg[i] <= 0;
                matrix_B_reg[i] <= 0;
           end
        end
        else begin
            for (int i = 0; i < 4; i++) begin
                matrix_A_reg[i] <= matrix_A[i];
                matrix_B_reg[i] <= matrix_B[i];
            end
        end
    end

    //Used generate statements to initialize the PE blocks.
    genvar i, j;
    generate
        for (i = 0; i < 4; i++) begin
            for (j = 0; j < 4; j++) begin
               PE uut(.clk(clk), 
                      .rst(rst), 
                      .PE_in_a(matrix_A_reg[i]), 
                      .PE_in_b(matrix_B_reg[j]), 
                      .PE_out_r(matrix_C_reg[i * 4 + j]));
            end
        end
    endgenerate

    always@(posedge clk or negedge rst) begin
        if (!rst) begin
           for (int i = 0; i < 16; i++) begin
                matrix_C[i] <= 0;
           end
        end
        else begin
            for (int i = 0; i < 16; i++) begin
                matrix_C[i] <= matrix_C_reg[i];
            end
        end
    end

endmodule