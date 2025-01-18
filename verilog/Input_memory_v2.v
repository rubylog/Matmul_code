module input_DP_mem_32b_256b(
    input clk_a, clk_b,
    input en_a, en_b,
    input [3:0] we_a, // we_a == 1111 for axi bram controller
    input [31:0] we_b, // doesn't use //
    input [8:0] addr_a, // 32 bit * '(8 * 64)' => 2^9
    input [5:0] addr_b, // (32 bit * 8) * 64 = (256 bit) * '64' => '64' = 2^6
    input [31:0] din_a, // axi bram controller
    input [255:0] din_b, // doesn't use //
    output reg [31:0] dout_a,
    output reg [255:0] dout_b
);

    (* ram_style = "block" *) reg [31:0] mem [0:8*64-1]; // ((128/2) cuz of packing / 4) x 64 cuz of packing 

    always @(posedge clk_a) begin
        if(en_a) begin
            if(|we_a) mem[addr_a] <= din_a;
            else dout_a <= mem[addr_a];
        end
    end

    // Parallel reading: 8 independent reads
    always @(posedge clk_b) begin // only read, connected to PL
        if (en_b) begin
            dout_b <= {
                mem[8 * addr_b + 0],  mem[8 * addr_b + 1],
                mem[8 * addr_b + 2],  mem[8 * addr_b + 3],
                mem[8 * addr_b + 4],  mem[8 * addr_b + 5],
                mem[8 * addr_b + 6],  mem[8 * addr_b + 7]
            };
        end
    end

endmodule