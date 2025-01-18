// Dual port memory

module output_memory#(
    parameter DATA_WIDTH = 16, // each row of A, each col of B
    parameter ADDR_WIDTH = 12 // log2(64*64=2^12)
)(
    input clk_a, clk_b,
    input en_a, en_b, // chip enable
    input we_a, we_b,
    input [ADDR_WIDTH-1:0] addr_a, addr_b,
    input [DATA_WIDTH-1:0] din_a, din_b,
    output reg [DATA_WIDTH-1:0] dout_a, dout_b // FF bur synthesis as bram resource
);

    (* ram_style = "block" *) reg [DATA_WIDTH-1:0] mem [(1<<ADDR_WIDTH)-1:0]; // FF

    always @(posedge clk_a) begin
        if(en_a) begin
            if(we_a) mem[addr_a] <= din_a; // write
            else dout_a <= mem[addr_a]; // read
        end
    end

    always @(posedge clk_b) begin
        if(en_b) begin
            if(we_b) mem[addr_b] <= din_b; // write
            else dout_b <= mem[addr_b]; // read
        end
    end

endmodule