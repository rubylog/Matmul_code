module Matmul_top#(
    parameter DATA_WIDTH = 16,
    parameter ARRAY_SIZE = 128
)(
    input clk_a, clk_b, // clk_a is 100MHz(PS), clk_b is 300MHz(PL)
    input rst_n,
    input start,
    input en_A_axi, en_B_axi,
    input en_out_axi,
    input [3:0] we_A_axi, we_B_axi,
    input we_out_axi,
    input [11:0] addr_A_axi, addr_B_axi,
    input [11:0] addr_out_axi,
    input [DATA_WIDTH*2 -1 : 0] din_A_axi, din_B_axi, dout_A_axi, dout_B_axi
    
    output [DATA_WIDTH-1:0] dout_out_axi,
    output done
);

    wire we_A, we_B, we_out;
    wire en_A, en_B, en_out;
    wire [5:0] addr_A, addr_B;
    wire [11:0] addr_out;

    // Input datas from two input Memory
    wire [ARRAY_SIZE * DATA_WIDTH-1:0] dout_A, dout_B;

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

    input_DP_mem_32b_2048b inmem_A (
        .clk_a(clk_a),
        .clk_b(clk_b),
        .en_a(en_A_axi),
        .en_b(en_B),
        .we_a(we_A_axi),
        .we_b(we_A),
        .addr_a(addr_A_axi),
        .addr_b(addr_A),
        .din_a(din_A_axi),
        .din_b(),
        .dout_a(dout_A_axi),
        .dout_b(dout_A)
    );

    input_DP_mem_32b_2048b inmem_B (
        .clk_a(clk_a),
        .clk_b(clk_b),
        .en_a(en_B_axi),
        .en_b(en_B),
        .we_a(we_B_axi),
        .we_b(we_B),
        .addr_a(addr_B_axi),
        .addr_b(addr_B),
        .din_a(din_B_axi),
        .din_b(),
        .dout_a(dout_B_axi),
        .dout_b(dout_B)
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