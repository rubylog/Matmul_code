/* THIS TOP MODULE USED FOR FPGA BLOCK DIAGRAM, BUT TOO MANY PORT -> ANNOYING TO DESIGN */
// Input bank include

module Matmul_top#(
    parameter DATA_WIDTH = 16,
    parameter ARRAY_SIZE = 128
)(
    // control signal
    input clk_a, clk_b, // clk_a is 100MHz(PS), clk_b is 300MHz(PL)
    input rst_n,
    input start,
    output done,

    // custom input bram axi interface for matrix A
    input en_A_a0, en_A_a1, en_A_a2, en_A_a3, en_A_a4, en_A_a5, en_A_a6, en_A_a7,
    input [3:0] we_A_a0, we_A_a1, we_A_a2, we_A_a3, we_A_a4, we_A_a5, we_A_a6, we_A_a7,
    input [8:0] addr_A_a0, addr_A_a1, addr_A_a2, addr_A_a3, addr_A_a4, addr_A_a5, addr_A_a6, addr_A_a7,
    input [31:0] din_A_a0, din_A_a1, din_A_a2, din_A_a3, din_A_a4, din_A_a5, din_A_a6, din_A_a7,

    output [31:0] dout_A_a0, dout_A_a1, dout_A_a2, dout_A_a3, dout_A_a4, dout_A_a5, dout_A_a6, dout_A_a7,

    // custom input bram axi interface for matrix B
    input en_B_a0, en_B_a1, en_B_a2, en_B_a3, en_B_a4, en_B_a5, en_B_a6, en_B_a7,
    input [3:0] we_B_a0, we_B_a1, we_B_a2, we_B_a3, we_B_a4, we_B_a5, we_B_a6, we_B_a7,
    input [8:0] addr_B_a0, addr_B_a1, addr_B_a2, addr_B_a3, addr_B_a4, addr_B_a5, addr_B_a6, addr_B_a7,
    input [31:0] din_B_a0, din_B_a1, din_B_a2, din_B_a3, din_B_a4, din_B_a5, din_B_a6, din_B_a7,

    output [31:0] dout_B_a0, dout_B_a1, dout_B_a2, dout_B_a3, dout_B_a4, dout_B_a5, dout_B_a6, dout_B_a7,

    // custom output bram axi interface // 32 bit * 32 col * 64 row
    input en_out_axi,
    input [3:0] we_out_axi,
    input [10:0] addr_out_axi,

    output [31:0] dout_out_axi
);

    wire we_out;
    wire en_out;
    wire [11:0] addr_out;

    // Data Merging
    wire [2047:0] merged_A, merged_B;

    wire [5:0] addr_b_unified_A, addr_b_unified_B;
    wire en_b_unified_A, en_b_unified_B;

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
        .en_A(en_b_unified_A),
        .en_B(en_b_unified_B),
        .en_out(en_out),
        .addr_a(addr_b_unified_A),
        .addr_b(addr_b_unified_B),
        .addr_out(addr_out),
        .done(done)
    );

    // Instantiate the inmem_bank module
    inmem_bank u_inmem_bank_A (
    .clk_a(clk_a),
    .clk_b(clk_b),
    .en_a0(en_A_a0),
    .en_a1(en_A_a1),
    .en_a2(en_A_a2),
    .en_a3(en_A_a3),
    .en_a4(en_A_a4),
    .en_a5(en_A_a5),
    .en_a6(en_A_a6),
    .en_a7(en_A_a7),
    .en_b_unified(en_b_unified_A),
    .we_a0(we_A_a0),
    .we_a1(we_A_a1),
    .we_a2(we_A_a2),
    .we_a3(we_A_a3),
    .we_a4(we_A_a4),
    .we_a5(we_A_a5),
    .we_a6(we_A_a6),
    .we_a7(we_A_a7),
    .din_a0(din_A_a0),
    .din_a1(din_A_a1),
    .din_a2(din_A_a2),
    .din_a3(din_A_a3),
    .din_a4(din_A_a4),
    .din_a5(din_A_a5),
    .din_a6(din_A_a6),
    .din_a7(din_A_a7),
    .addr_a0(addr_A_a0),
    .addr_a1(addr_A_a1),
    .addr_a2(addr_A_a2),
    .addr_a3(addr_A_a3),
    .addr_a4(addr_A_a4),
    .addr_a5(addr_A_a5),
    .addr_a6(addr_A_a6),
    .addr_a7(addr_A_a7),
    .addr_b_unified(addr_b_unified_A),
    .dout_a0(dout_A_a0),
    .dout_a1(dout_A_a1),
    .dout_a2(dout_A_a2),
    .dout_a3(dout_A_a3),
    .dout_a4(dout_A_a4),
    .dout_a5(dout_A_a5),
    .dout_a6(dout_A_a6),
    .dout_a7(dout_A_a7),
    .dout_b_merged(merged_A)
    );

    // Instantiate the inmem_bank module
    inmem_bank u_inmem_bank_B (
        .clk_a(clk_a),
        .clk_b(clk_b),
        .en_b0(en_B_a0),
        .en_b1(en_B_a1),
        .en_b2(en_B_a2),
        .en_b3(en_B_a3),
        .en_b4(en_B_a4),
        .en_b5(en_B_a5),
        .en_b6(en_B_a6),
        .en_b7(en_B_a7),
        .en_b_unified(en_b_unified_B),
        .we_b0(we_B_a0),
        .we_b1(we_B_a1),
        .we_b2(we_B_a2),
        .we_b3(we_B_a3),
        .we_b4(we_B_a4),
        .we_b5(we_B_a5),
        .we_b6(we_B_a6),
        .we_b7(we_B_a7),
        .din_b0(din_B_a0),
        .din_b1(din_B_a1),
        .din_b2(din_B_a2),
        .din_b3(din_B_a3),
        .din_b4(din_B_a4),
        .din_b5(din_B_a5),
        .din_b6(din_B_a6),
        .din_b7(din_B_a7),
        .addr_b0(addr_B_a0),
        .addr_b1(addr_B_a1),
        .addr_b2(addr_B_a2),
        .addr_b3(addr_B_a3),
        .addr_b4(addr_B_a4),
        .addr_b5(addr_B_a5),
        .addr_b6(addr_B_a6),
        .addr_b7(addr_B_a7),
        .addr_b_unified(addr_b_unified_B),
        .dout_b0(dout_B_a0),
        .dout_b1(dout_B_a1),
        .dout_b2(dout_B_a2),
        .dout_b3(dout_B_a3),
        .dout_b4(dout_B_a4),
        .dout_b5(dout_B_a5),
        .dout_b6(dout_B_a6),
        .dout_b7(dout_B_a7),
        .dout_b_merged(merged_B)
    );


    // Instantiate the PE_array_top module
    PE_array_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .ARRAY_SIZE(ARRAY_SIZE),
        .ROW_SIZE(16)
    ) pe_top (
        .A(merged_A),
        .B(merged_B),
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