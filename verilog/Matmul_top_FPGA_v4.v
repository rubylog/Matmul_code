/* THIS TOP MODULE USED FOR FPGA BLOCK DIAGRAM - FINAL USED */
// Input Memory doesn't include
// using dual port bram ip 32b to 1024b

module Matmul_top#(
    parameter DATA_WIDTH = 16,
    parameter ARRAY_SIZE = 128
)(
    input clk_a, clk_b, // clk_a is 100MHz(PS), clk_b is 300MHz(PL)
    input rst_n,
    input start,

    // custom output bram axi interface // 32 bit * 32 col * 64 row
    input en_out_axi,
    input [3:0] we_out_axi,
    input [10:0] addr_out_axi,

    output [31:0] dout_out_axi,

    // conneted from bram ip interface // 256 bit * 64 row * #8 for both A and B
    input [1023:0] dout_A_MSB, dout_B_MSB,
    input [1023:0] dout_A_LSB, dout_B_LSB,

    output we_A, we_B, // for port b of axi bram
    output en_A, en_B,
    output [5:0] addr_A, addr_B,

    output done
);

    wire we_out;
    wire en_out;
    wire [11:0] addr_out;

    // Data Merging
    wire [DATA_WIDTH*ARRAY_SIZE-1:0] dout_A, dout_B;

    assign dout_A = {dout_A_MSB, dout_A_LSB};
    assign dout_B = {dout_B_MSB, dout_B_LSB};

    // PE Outputs
    wire [(DATA_WIDTH * ARRAY_SIZE) - 1:0] PE_result;

    // Adder Tree output
    wire [DATA_WIDTH-1:0] Adder_tree_result;

    // Instantiate the memory_controller module
    memory_controller mem_control (
        .clk(clk_b),
        .rst_n(rst_n),
        .start(start),
        .we_A(we_A),
        .we_B(we_B),
        .we_out(we_out),
        .en_A(en_A),
        .en_B(en_B),
        .en_out(en_out),
        .addr_a(addr_A),
        .addr_b(addr_B),
        .addr_out(addr_out),
        .done(done)
    );

    // Instantiate the PE_array_top module
    PE_array_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .ARRAY_SIZE(ARRAY_SIZE),
        .ROW_SIZE(16)
    ) pe_top (
        .A(dout_A),
        .B(dout_B),
        .Mul(PE_result)
    );

    // Instantiate the adder_tree module
    adder_tree #(
        .DATA_WIDTH(DATA_WIDTH),
        .ARRAY_SIZE(ARRAY_SIZE)
    ) addtree (
        .clk(clk_b),
        .rst_n(rst_n),
        .PE_result(PE_result),
        .layer7_out_reg(Adder_tree_result)
    );

    // Instantiate the output_memory module
    // port b is connected to PL.
    output_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(12)
    ) outmem (
        .clk_a(clk_a),
        .clk_b(clk_b),
        .en_a(en_out_axi),
        .en_b(en_out),
        .we_a(we_out_axi),
        .we_b(we_out),
        .addr_a(addr_out_axi),
        .addr_b(addr_out),
        .din_a(),
        .din_b(Adder_tree_result),
        .dout_a(dout_out_axi),
        .dout_b()
    );

endmodule