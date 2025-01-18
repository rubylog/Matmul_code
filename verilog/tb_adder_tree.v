`timescale 1ns / 1ps

module adder_tree_tb;

    // Parameters
    parameter DATA_WIDTH = 16;
    parameter ARRAY_SIZE = 128;

    // Inputs
    reg clk;
    reg rst_n;
    reg [(DATA_WIDTH * ARRAY_SIZE) - 1 : 0] PE_result;

    // Outputs
    wire [DATA_WIDTH - 1 : 0] layer7_out_wire;

    // Instantiate the Unit Under Test (UUT)
    adder_tree #(
        .DATA_WIDTH(DATA_WIDTH),
        .ARRAY_SIZE(ARRAY_SIZE)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .PE_result(PE_result),
        .layer7_out_reg(layer7_out_wire)
    );

    reg [DATA_WIDTH-1:0] input_mem_A [ARRAY_SIZE-1:0];
    reg [DATA_WIDTH-1:0] input_mem_B [ARRAY_SIZE-1:0]; // for check pipelining

    integer i;
    integer file; // 파일 핸들러

    initial begin
        PE_result = 0;
        #20
        // 파일에서 데이터 읽기
        $readmemb("C:\\Users\\conqu\\Desktop\\2025_winter\\0110\\vs_code\\python\\input_A_exp135_raw.txt", input_mem_A);
        $readmemb("C:\\Users\\conqu\\Desktop\\2025_winter\\0110\\vs_code\\python\\input_B_exp135_raw.txt", input_mem_B);

        // input_mem_A와 input_mem_B의 값을 A와 B로 변환하여 저장
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            PE_result[((ARRAY_SIZE-i)*DATA_WIDTH - 1) -: DATA_WIDTH] = input_mem_A[ARRAY_SIZE - 1 - i];
        end

        #10 // after 1 clk period

        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            PE_result[((ARRAY_SIZE-i)*DATA_WIDTH - 1) -: DATA_WIDTH] = input_mem_B[ARRAY_SIZE - 1 - i];
        end
    end

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Test sequence
    initial begin
        rst_n = 1;
        #10 // rst
        rst_n = 0; 
        #10
        rst_n = 1; // data_A in, start calculation

        #10 // data_B in after 1 clk

        #100 // check finishing time , clk unit

        
        $stop;
    end

    // Monitor outputs
    initial begin
        forever begin
            #10; // Print every 10 time units
            $display("Time: %0t, layer7_out_wire: %h", $time, layer7_out_wire);
        end
    end

endmodule
