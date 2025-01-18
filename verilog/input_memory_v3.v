// top module for input_memory_v2.v
// signal with a : connected to axi bram controller
// signal with b : connected to matmul PL

module inmem_bank(
    input clk_a, clk_b,
    input en_a0, en_a1, en_a2, en_a3, en_a4, en_a5, en_a6, en_a7,
    input en_b_unified,
    input [3:0] we_a0, we_a1, we_a2, we_a3, we_a4, we_a5, we_a6, we_a7,
    input [31:0] din_a0, din_a1, din_a2, din_a3, din_a4, din_a5, din_a6, din_a7,
    input [8:0] addr_a0, addr_a1, addr_a2, addr_a3, addr_a4, addr_a5, addr_a6, addr_a7,
    input [5:0] addr_b_unified,

    output [31:0] dout_a0, dout_a1, dout_a2, dout_a3, dout_a4, dout_a5, dout_a6, dout_a7,
    output [2047:0] dout_b_merged
);

/// Instantiate 8 banks of dual-port memories
input_DP_mem_32b_256b mem_bank0 (
    .clk_a(clk_a),
    .clk_b(clk_b),
    .en_a(en_a0),
    .en_b(en_b_unified),
    .we_a(we_a0),
    .we_b(32'b0),
    .addr_a(addr_a0),
    .addr_b(addr_b_unified),
    .din_a(din_a0),
    .din_b(256'b0),
    .dout_a(dout_a0),
    .dout_b(dout_b_merged[2047 -: 256])
);

input_DP_mem_32b_256b mem_bank1 (
    .clk_a(clk_a),
    .clk_b(clk_b),
    .en_a(en_a1),
    .en_b(en_b_unified),
    .we_a(we_a1),
    .we_b(32'b0),
    .addr_a(addr_a1),
    .addr_b(addr_b_unified),
    .din_a(din_a1),
    .din_b(256'b0),
    .dout_a(dout_a1),
    .dout_b(dout_b_merged[1791 -: 256])
);

input_DP_mem_32b_256b mem_bank2 (
    .clk_a(clk_a),
    .clk_b(clk_b),
    .en_a(en_a2),
    .en_b(en_b_unified),
    .we_a(we_a2),
    .we_b(32'b0),
    .addr_a(addr_a2),
    .addr_b(addr_b_unified),
    .din_a(din_a2),
    .din_b(256'b0),
    .dout_a(dout_a2),
    .dout_b(dout_b_merged[1535 -: 256])
);

input_DP_mem_32b_256b mem_bank3 (
    .clk_a(clk_a),
    .clk_b(clk_b),
    .en_a(en_a3),
    .en_b(en_b_unified),
    .we_a(we_a3),
    .we_b(32'b0),
    .addr_a(addr_a3),
    .addr_b(addr_b_unified),
    .din_a(din_a3),
    .din_b(256'b0),
    .dout_a(dout_a3),
    .dout_b(dout_b_merged[1279 -: 256])
);

input_DP_mem_32b_256b mem_bank4 (
    .clk_a(clk_a),
    .clk_b(clk_b),
    .en_a(en_a4),
    .en_b(en_b_unified),
    .we_a(we_a4),
    .we_b(32'b0),
    .addr_a(addr_a4),
    .addr_b(addr_b_unified),
    .din_a(din_a4),
    .din_b(256'b0),
    .dout_a(dout_a4),
    .dout_b(dout_b_merged[1023 -: 256])
);

input_DP_mem_32b_256b mem_bank5 (
    .clk_a(clk_a),
    .clk_b(clk_b),
    .en_a(en_a5),
    .en_b(en_b_unified),
    .we_a(we_a5),
    .we_b(32'b0),
    .addr_a(addr_a5),
    .addr_b(addr_b_unified),
    .din_a(din_a5),
    .din_b(256'b0),
    .dout_a(dout_a5),
    .dout_b(dout_b_merged[767 -: 256])
);

input_DP_mem_32b_256b mem_bank6 (
    .clk_a(clk_a),
    .clk_b(clk_b),
    .en_a(en_a6),
    .en_b(en_b_unified),
    .we_a(we_a6),
    .we_b(32'b0),
    .addr_a(addr_a6),
    .addr_b(addr_b_unified),
    .din_a(din_a6),
    .din_b(256'b0),
    .dout_a(dout_a6),
    .dout_b(dout_b_merged[511 -: 256])
);

input_DP_mem_32b_256b mem_bank7 (
    .clk_a(clk_a),
    .clk_b(clk_b),
    .en_a(en_a7),
    .en_b(en_b_unified),
    .we_a(we_a7),
    .we_b(32'b0),
    .addr_a(addr_a7),
    .addr_b(addr_b_unified),
    .din_a(din_a7),
    .din_b(256'b0),
    .dout_a(dout_a7),
    .dout_b(dout_b_merged[255 -: 256])
);

endmodule
