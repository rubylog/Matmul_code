module input_DP_mem_32b_2048b(
    input clk_a, clk_b,
    input en_a, en_b,
    input [3:0] we_a, // we_a == 1111 for axi bram controller
    input we_b,
    input [11:0] addr_a,
    input [5:0] addr_b, // # 32 bit data = 64 -> log2(64) = 6 // changes 0 ~ 63
    input [31:0] din_a, // axi
    input [2047:0] din_b,
    output reg [31:0] dout_a,
    output reg [2047:0] dout_b
);

    (* ram_style = "block" *) reg [31:0] mem [0:64*64-1]; // 64 x (128/2) cuz of packing 

    always @(posedge clk_a) begin
        if(en_a) begin
            if(|we_a) mem_a[addr_a] <= din_a;
            else dout_a <= mem[addr_a];
        end
    end

    // Parallel reading: 64 independent reads
        always @(posedge clk_b) begin
            if (en_b) begin
                dout_b <= {
                    mem[64 * addr_b + 0],  mem[64 * addr_b + 1],  mem[64 * addr_b + 2],
                    mem[64 * addr_b + 3],  mem[64 * addr_b + 4],  mem[64 * addr_b + 5],
                    mem[64 * addr_b + 6],  mem[64 * addr_b + 7],  mem[64 * addr_b + 8],
                    mem[64 * addr_b + 9],  mem[64 * addr_b + 10], mem[64 * addr_b + 11],
                    mem[64 * addr_b + 12], mem[64 * addr_b + 13], mem[64 * addr_b + 14],
                    mem[64 * addr_b + 15], mem[64 * addr_b + 16], mem[64 * addr_b + 17],
                    mem[64 * addr_b + 18], mem[64 * addr_b + 19], mem[64 * addr_b + 20],
                    mem[64 * addr_b + 21], mem[64 * addr_b + 22], mem[64 * addr_b + 23],
                    mem[64 * addr_b + 24], mem[64 * addr_b + 25], mem[64 * addr_b + 26],
                    mem[64 * addr_b + 27], mem[64 * addr_b + 28], mem[64 * addr_b + 29],
                    mem[64 * addr_b + 30], mem[64 * addr_b + 31], mem[64 * addr_b + 32],
                    mem[64 * addr_b + 33], mem[64 * addr_b + 34], mem[64 * addr_b + 35],
                    mem[64 * addr_b + 36], mem[64 * addr_b + 37], mem[64 * addr_b + 38],
                    mem[64 * addr_b + 39], mem[64 * addr_b + 40], mem[64 * addr_b + 41],
                    mem[64 * addr_b + 42], mem[64 * addr_b + 43], mem[64 * addr_b + 44],
                    mem[64 * addr_b + 45], mem[64 * addr_b + 46], mem[64 * addr_b + 47],
                    mem[64 * addr_b + 48], mem[64 * addr_b + 49], mem[64 * addr_b + 50],
                    mem[64 * addr_b + 51], mem[64 * addr_b + 52], mem[64 * addr_b + 53],
                    mem[64 * addr_b + 54], mem[64 * addr_b + 55], mem[64 * addr_b + 56],
                    mem[64 * addr_b + 57], mem[64 * addr_b + 58], mem[64 * addr_b + 59],
                    mem[64 * addr_b + 60], mem[64 * addr_b + 61], mem[64 * addr_b + 62],
                    mem[64 * addr_b + 63]
                };
            end
        end

endmodule
