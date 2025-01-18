// Dual port memory
// for each input A and B
// bitwidth is 128*16 bram max port - 1024: # 36kb block = 2 (sero) 
// addr(depth) is 64 : garo 2
// <- depth
// b b --- ports
// b b ---

module input_memory#(
    parameter ARRAY_SIZE = 128,
    parameter DATA_WIDTH = 16, // each row of A, each col of B
    parameter ADDR_WIDTH = 6 // log2(64)
)(
    input clk,
    input en_a, en_b, // chip enable
    input we_a, we_b,
    input [ADDR_WIDTH-1:0] addr_a, addr_b,
    input [ARRAY_SIZE * DATA_WIDTH-1:0] din_a, din_b,
    output reg [ARRAY_SIZE * DATA_WIDTH-1:0] dout_a, dout_b // FF bur synthesis as bram resource
);

    (* ram_style = "block" *) reg [ARRAY_SIZE * DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1]; // FF

    always @(posedge clk) begin
        if(en_a) begin
            if(we_a) mem[addr_a] <= din_a; // write
            else dout_a <= mem[addr_a]; // read
        end
    end

    always @(posedge clk) begin
        if(en_b) begin
            if(we_b) mem[addr_b] <= din_b; // write
            else dout_b <= mem[addr_b]; // read
        end
    end

endmodule