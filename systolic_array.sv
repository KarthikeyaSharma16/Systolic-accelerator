`timescale 1ns/1ps

module systolic_array (
    input clk,
    input rst,
    input logic [31:0] matrix_A [3:0], 
    input logic [31:0] matrix_B [3:0],
    output logic [31:0] matrix_C [15:0]
);

    logic [4:0] ip_counter;
    logic [5:0] op_counter;

    logic [31:0] matrix_A_reg [3:0];
    logic [31:0] matrix_B_reg [3:0];
    logic [31:0] matrix_C_reg [15:0];

    always@(posedge clk or negedge rst) begin
        if (!rst) begin
           ip_counter <= 0; 
           for (int i = 0; i < 4; i++) begin
                matrix_A_reg[i] <= 0;
                matrix_B_reg[i] <= 0;
           end
        end
        else begin
            if (ip_counter == 10) begin
                for (int i = 0; i < 4; i++) begin
                    matrix_A_reg[i] <= matrix_A[i];
                    matrix_B_reg[i] <= matrix_B[i];
                end
                ip_counter <= 0;
            end
            else begin
            ip_counter <= ip_counter + 1;
            end
        end
    end

    //Row-1
    PE uut_1(.clk(clk), .rst(rst), .PE_in_a(matrix_A_reg[0]), .PE_in_b(matrix_B_reg[0]), .PE_out_r(matrix_C_reg[0]));
    PE uut_2(.clk(clk), .rst(rst), .PE_in_a(matrix_A_reg[0]), .PE_in_b(matrix_B_reg[1]), .PE_out_r(matrix_C_reg[1]));
    PE uut_3(.clk(clk), .rst(rst), .PE_in_a(matrix_A_reg[0]), .PE_in_b(matrix_B_reg[2]), .PE_out_r(matrix_C_reg[2]));
    PE uut_4(.clk(clk), .rst(rst), .PE_in_a(matrix_A_reg[0]), .PE_in_b(matrix_B_reg[3]), .PE_out_r(matrix_C_reg[3]));
    
    //Row-2
    PE uut_6(.clk(clk), .rst(rst), .PE_in_a(matrix_A_reg[1]), .PE_in_b(matrix_B_reg[1]), .PE_out_r(matrix_C_reg[5]));
    PE uut_7(.clk(clk), .rst(rst), .PE_in_a(matrix_A_reg[1]), .PE_in_b(matrix_B_reg[2]), .PE_out_r(matrix_C_reg[6]));
    PE uut_5(.clk(clk), .rst(rst), .PE_in_a(matrix_A_reg[1]), .PE_in_b(matrix_B_reg[0]), .PE_out_r(matrix_C_reg[4]));
    PE uut_8(.clk(clk), .rst(rst), .PE_in_a(matrix_A_reg[1]), .PE_in_b(matrix_B_reg[3]), .PE_out_r(matrix_C_reg[7]));
    
    //Row-3
    PE uut_9(.clk(clk), .rst(rst), .PE_in_a(matrix_A_reg[2]), .PE_in_b(matrix_B_reg[0]), .PE_out_r(matrix_C_reg[8]));
    PE uut_10(.clk(clk), .rst(rst), .PE_in_a(matrix_A_reg[2]), .PE_in_b(matrix_B_reg[1]), .PE_out_r(matrix_C_reg[9]));
    PE uut_11(.clk(clk), .rst(rst), .PE_in_a(matrix_A_reg[2]), .PE_in_b(matrix_B_reg[2]), .PE_out_r(matrix_C_reg[10]));
    PE uut_12(.clk(clk), .rst(rst), .PE_in_a(matrix_A_reg[2]), .PE_in_b(matrix_B_reg[3]), .PE_out_r(matrix_C_reg[11]));
    
    //Row-4
    PE uut_13(.clk(clk), .rst(rst), .PE_in_a(matrix_A_reg[3]), .PE_in_b(matrix_B_reg[0]), .PE_out_r(matrix_C_reg[12]));
    PE uut_14(.clk(clk), .rst(rst), .PE_in_a(matrix_A_reg[3]), .PE_in_b(matrix_B_reg[1]), .PE_out_r(matrix_C_reg[13]));
    PE uut_15(.clk(clk), .rst(rst), .PE_in_a(matrix_A_reg[3]), .PE_in_b(matrix_B_reg[2]), .PE_out_r(matrix_C_reg[14]));
    PE uut_16(.clk(clk), .rst(rst), .PE_in_a(matrix_A_reg[3]), .PE_in_b(matrix_B_reg[3]), .PE_out_r(matrix_C_reg[15]));

    always@(posedge clk or negedge rst) begin
        if (!rst) begin
           op_counter <= 0;
           for (int i = 0; i < 16; i++) begin
                matrix_C[i] <= 0;
                $display("matrix_C[i] = %0x", matrix_C[i]);
           end
        end
        else begin
            
            if (op_counter == 40) begin
                for (int i = 0; i < 16; i++) begin
                    $display("matrix_C[i] = %0x", matrix_C[i]);
                    matrix_C[i] <= matrix_C_reg[i];
                end
            end
            else begin
                op_counter <= op_counter + 1;
            end
        end
    end

endmodule