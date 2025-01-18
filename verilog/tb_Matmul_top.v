`timescale 1ns / 1ps

module Matmul_top_tb;

    // Parameters
    localparam DATA_WIDTH = 16;
    localparam ARRAY_SIZE = 128;

    // Inputs
    reg clk;
    reg rst_n;
    reg start;
    reg en_A_axi, en_B_axi, en_out_axi;
    reg [3:0] we_A_axi, we_B_axi, we_out_axi;
    reg [11:0] addr_A_axi, addr_B_axi;
    reg [10:0] addr_out_axi;
    reg [DATA_WIDTH*2 - 1:0] din_A_axi, din_B_axi; // 32 bits (packing 2 data)

    // Outputs
    wire [DATA_WIDTH*2 - 1 : 0] dout_A_axi, dout_B_axi;
    wire [DATA_WIDTH*2 - 1:0] dout_out_axi;
    wire done;

    // Instantiation of Matmul_top
    Matmul_top #(
        .DATA_WIDTH(DATA_WIDTH),       // Specify the data width
        .ARRAY_SIZE(ARRAY_SIZE)       // Specify the array size
    ) u_Matmul_top (
        .clk_a(clk_a),          // 100MHz clock input (PS)
        .clk_b(clk_b),          // 300MHz clock input (PL)
        .rst_n(rst_n),          // Active low reset
        .start(start),          // Start signal
        .en_A_axi(en_A_axi),    // Enable signal for AXI interface A
        .en_B_axi(en_B_axi),    // Enable signal for AXI interface B
        .en_out_axi(en_out_axi),// Enable signal for AXI output interface
        .we_A_axi(we_A_axi),    // Write enable for AXI interface A
        .we_B_axi(we_B_axi),    // Write enable for AXI interface B
        .we_out_axi(we_out_axi),// Write enable for AXI output interface
        .addr_A_axi(addr_A_axi),// Address for AXI interface A
        .addr_B_axi(addr_B_axi),// Address for AXI interface B
        .addr_out_axi(addr_out_axi), // Address for AXI output interface
        .din_A_axi(din_A_axi),  // Data input for AXI interface A
        .din_B_axi(din_B_axi),  // Data input for AXI interface B
        .dout_A_axi(dout_A_axi),// Debugging output for AXI interface A
        .dout_B_axi(dout_B_axi),// Debugging output for AXI interface B
        .dout_out_axi(dout_out_axi), // Data output for AXI output interface
        .done(done)             // Done signal
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    wire clk_a, clk_b;
    assign clk_a = clk;
    assign clk_b = clk;

    reg [DATA_WIDTH*ARRAY_SIZE-1:0] input_matrix_A [63:0]; // 64 x 128 
    reg [DATA_WIDTH*ARRAY_SIZE-1:0] input_matrix_B [63:0]; // 64 x 128 (transpose)
    reg [DATA_WIDTH*64-1:0] output_Matrix [63:0]; // 64 x 64

    integer i, k;
    integer file;

    initial begin
        rst_n = 0;
        start = 0;
        en_A_axi = 0;
        en_B_axi = 0;
        en_out_axi = 0;
        we_A_axi = 0;
        we_B_axi = 0;
        we_out_axi = 0;
        addr_A_axi = 0;
        addr_B_axi = 0;
        addr_out_axi = 0;
        din_A_axi = 0;
        din_B_axi = 0;

        #10
        rst_n = 1;
        en_A_axi = 1; we_A_axi = 4'b1111; addr_A_axi = 6'h00; 
        en_B_axi = 1; we_B_axi = 4'b1111; addr_B_axi = 6'h00;

        #10
        $readmemb("C:\\Users\\conqu\\Desktop\\2025_winter\\0119\\Matmul_code\\python\\A_64x128_raw.txt", input_matrix_A);
        $readmemb("C:\\Users\\conqu\\Desktop\\2025_winter\\0119\\Matmul_code\\python\\B_64x128_raw.txt", input_matrix_B);

        for (i = 0; i < 64; i = i + 1) begin
            for (k = 0; k < 64; k = k + 1) begin // 16 bit * 128 elements == 32 bit * 64 elements
                din_A_axi = input_matrix_A[i][(DATA_WIDTH*ARRAY_SIZE)-1 - 32*k -: 32]; // group to 32 bit
                din_B_axi = input_matrix_B[i][(DATA_WIDTH*ARRAY_SIZE)-1 - 32*k -: 32];
                #10 // for each clk
                addr_A_axi = addr_A_axi + 1; // overflow occur at addr == 64, but escape the loop -> not a problem
                addr_B_axi = addr_B_axi + 1;
            end
        end

        en_A_axi = 0; we_A_axi = 0;
        en_B_axi = 0; we_B_axi = 0;

        #20

        start = 1;

        wait(done);

        #15
        en_out_axi = 1; we_out_axi = 0; addr_out_axi = 6'h00;  // read only
        
        #10 
        for (k = 0; k < 64; k = k + 1) begin // 64 row 
            for (i = 0; i < 32; i = i + 1) begin // 32 col for 32 bit reading
                addr_out_axi = addr_out_axi + 1;
                output_Matrix[63 - k][DATA_WIDTH*64 - 1 - 32*i -: DATA_WIDTH*2] = dout_out_axi;

                #10;
            end
        end


        file = $fopen("C:\\Users\\conqu\\Desktop\\2025_winter\\0119\\Matmul_code\\python\\tb_OUTPUT_64x64_raw.txt", "w");
            if (file == 0) begin
                $display("Error: Could not open file.");
                $stop;
            end

        for (k = 0; k < 64; k = k + 1) begin
            $fwrite(file, "%b\n", output_Matrix[63 - k]);
        end

        $fclose(file);

        $display("Simulation completed. Results saved to tb_OUTPUT_64x64_raw.txt.");

        $stop;

    end

endmodule
