`timescale 1ns / 1ps

module BF_adder_tb;

    // Parameters
    localparam BIAS = 127;
    localparam ARRAY_SIZE = 128;
    localparam DATA_WIDTH = 16;

    // Inputs
    reg [15:0] num1;
    reg [15:0] num2;

    // Outputs
    wire [15:0] sum;

    // Instantiate the Unit Under Test (UUT)
    BF_adder #(BIAS) uut (
        .num1(num1),
        .num2(num2),
        .sum(sum)
    );

    reg [DATA_WIDTH-1:0] input_mem_A [ARRAY_SIZE-1:0];
    reg [DATA_WIDTH-1:0] input_mem_B [ARRAY_SIZE-1:0];
    reg [DATA_WIDTH-1:0] Add_mem [ARRAY_SIZE-1:0];

    integer i;
    integer file; // ?��?�� ?��?��?��

    initial begin
        #10;
        $display("Simulation started.");


        // Open input and output files
        $readmemb("C:\\Users\\conqu\\Desktop\\2025_winter\\0110\\vs_code\\python\\input_A_exp135_raw.txt", input_mem_A);
        $readmemb("C:\\Users\\conqu\\Desktop\\2025_winter\\0110\\vs_code\\python\\input_B_exp135_raw.txt", input_mem_B);

        // Process inputs and write results
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            num1 = input_mem_A[ARRAY_SIZE - 1 - i];
            num2 = input_mem_B[ARRAY_SIZE - 1 - i];
            #10
            Add_mem[ARRAY_SIZE - 1 - i] = sum;
            $display("Iteration %0d: num1=%b, num2=%b, sum=%b", i, num1, num2, sum);
        end

    end

    integer k;
    
    initial begin

        // 결과 ?��?�� ?���?
        file = $fopen("C:\\Users\\conqu\\Desktop\\2025_winter\\0110\\vs_code\\verilog\\output_Add.txt", "w");
        if (file == 0) begin
            $display("Error: Could not open file.");
            $stop;
        end

        #1300

        for (k = 0; k < ARRAY_SIZE; k = k + 1) begin
            $fwrite(file, "%b\n", Add_mem[ARRAY_SIZE- 1 - k]);
        end

        #10

        // ?��?�� ?���?
        $fclose(file);

        $display("Simulation completed. Results saved to output_Add.txt.");

        // 종료
        $stop;
    end



endmodule