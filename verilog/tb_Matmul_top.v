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
    reg we_A_axi, we_B_axi, we_out_axi;
    reg [5:0] addr_A_axi, addr_B_axi;
    reg [11:0] addr_out_axi;
    reg [(ARRAY_SIZE * DATA_WIDTH) / 2 - 1 : 0] din_A_axi_MSB, din_A_axi_LSB, din_B_axi_MSB, din_B_axi_LSB; // 64*data

    // Outputs
    wire [DATA_WIDTH - 1:0] dout_out_axi;
    wire done;

    // Instantiate the Matmul_top module
    Matmul_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .ARRAY_SIZE(ARRAY_SIZE)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .en_A_axi(en_A_axi),
        .en_B_axi(en_B_axi),
        .en_out_axi(en_out_axi),
        .we_A_axi(we_A_axi),
        .we_B_axi(we_B_axi),
        .we_out_axi(we_out_axi),
        .addr_A_axi(addr_A_axi),
        .addr_B_axi(addr_B_axi),
        .addr_out_axi(addr_out_axi),
        .din_A_axi_MSB(din_A_axi_MSB),
        .din_A_axi_LSB(din_A_axi_LSB),
        .din_B_axi_MSB(din_B_axi_MSB),
        .din_B_axi_LSB(din_B_axi_LSB),
        .dout_out_axi(dout_out_axi),
        .done(done)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;


    reg [DATA_WIDTH*ARRAY_SIZE-1:0] input_matrix_A [63:0]; // 64 x 128 
    reg [DATA_WIDTH*ARRAY_SIZE-1:0] input_matrix_B [63:0]; // 64 x 128 (transpose)
    reg [DATA_WIDTH*64-1:0] output_Matrix [63:0]; // 64 x 64

    integer i, k;
    integer file; // ?ï¿½ï¿½?ï¿½ï¿½ ?ï¿½ï¿½?ï¿½ï¿½?ï¿½ï¿½

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
        din_A_axi_MSB = 0;
        din_A_axi_LSB = 0;
        din_B_axi_MSB = 0;
        din_B_axi_LSB = 0;

        #10
        rst_n = 1;
        en_A_axi = 1; we_A_axi = 1; addr_A_axi = 6'h00; 
        en_B_axi = 1; we_B_axi = 1; addr_B_axi = 6'h00;

        #10
        // ?ï¿½ï¿½?ï¿½ï¿½?ï¿½ï¿½?ï¿½ï¿½ ?ï¿½ï¿½?ï¿½ï¿½?ï¿½ï¿½ ?ï¿½ï¿½ï¿???
        $readmemb("C:\\Users\\conqu\\Desktop\\2025_winter\\0110\\vs_code\\python\\input_64x128_A_raw.txt", input_matrix_A);
        $readmemb("C:\\Users\\conqu\\Desktop\\2025_winter\\0110\\vs_code\\python\\input_64x128_B_raw.txt", input_matrix_B);

        // input_mem_A?? input_mem_B?ï¿½ï¿½ ê°’ì„ A?? Bï¿??? ï¿????ï¿½ï¿½?ï¿½ï¿½?ï¿½ï¿½ ???ï¿½ï¿½
        for (i = 0; i < 64; i = i + 1) begin
            din_A_axi_MSB = input_matrix_A[i][(DATA_WIDTH*ARRAY_SIZE)-1 -: (DATA_WIDTH*ARRAY_SIZE)/2];
            din_A_axi_LSB = input_matrix_A[i][(DATA_WIDTH*ARRAY_SIZE)/2 -1 : 0];
            din_B_axi_MSB = input_matrix_B[i][(DATA_WIDTH*ARRAY_SIZE)-1 -: (DATA_WIDTH*ARRAY_SIZE)/2];
            din_B_axi_LSB = input_matrix_B[i][(DATA_WIDTH*ARRAY_SIZE)/2 -1 : 0];
            #10 // for each clk
            addr_A_axi = addr_A_axi + 1; // overflow occur at addr == 64, but escape the loop -> not a problem
            addr_B_axi = addr_B_axi + 1;
        end

        en_A_axi = 0; we_A_axi = 0;
        en_B_axi = 0; we_B_axi = 0;

        #20

        start = 1;

        wait(done);

        #15
        en_out_axi = 1; we_out_axi = 0; addr_out_axi = 6'h00;  // read only
        
        #10 // enable?ï¿½ï¿½ï¿?? ë©”ëª¨ï¿?? (dout_out_axi) ?ï¿½ï¿½?ï¿½ï¿½?ï¿½ï¿½ ?ï¿½ï¿½ ?ï¿½ï¿½?ï¿½ï¿½ ê±¸ë¦¼
        for (k = 0; k < 64*64; k = k + 1) begin
            addr_out_axi = addr_out_axi + 1;
            // ?ï¿½ï¿½(row)?? ?ï¿½ï¿½(column) ê³„ì‚°
            output_Matrix[63 - (k / 64)][DATA_WIDTH*(64 - k % 64) - 1 -: DATA_WIDTH] = dout_out_axi;

            $display("Time: %0t | dout_out_axi: %b | Matrix[%0d][%0d] = %b",
                     $time, dout_out_axi, (k / 64), (k % 64), dout_out_axi);

            #10;
            
        end


        file = $fopen("C:\\Users\\conqu\\Desktop\\2025_winter\\0110\\vs_code\\verilog\\output_Matrix.txt", "w");
            if (file == 0) begin
                $display("Error: Could not open file.");
                $stop;
            end

        for (k = 0; k < 64; k = k + 1) begin
            $fwrite(file, "%b\n", output_Matrix[63 - k]);
        end

        $fclose(file);

        $display("Simulation completed. Results saved to output_Matrix.txt.");

        $stop;

    end

endmodule
