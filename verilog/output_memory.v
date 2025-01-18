// Dual port memory

module output_memory#(
    parameter DATA_WIDTH = 16, // each row of A, each col of B
    parameter ADDR_WIDTH = 12 // log2(64*64=2^12)
)(
    input clk_a, clk_b,
    input en_a, en_b, // chip enable
    input [3:0] we_a, 
    input we_b,
    input [ADDR_WIDTH-2:0] addr_a, // divide by 2 (cuz 16 bit data -> 32 bit data)
    input [ADDR_WIDTH-1:0] addr_b,
    input [DATA_WIDTH*2-1:0] din_a,
    input [DATA_WIDTH-1:0] din_b,
    output reg [DATA_WIDTH*2-1:0] dout_a,
    output reg [DATA_WIDTH-1:0] dout_b
);

    (* ram_style = "block" *) reg [DATA_WIDTH-1:0] mem [(1<<ADDR_WIDTH)-1:0]; // FF

    always @(posedge clk_a) begin // only read, connected to axi
        if(en_a) begin
            dout_a <= {
                mem[2*addr_a + 0], mem[2*addr_a + 1]
            };
        end
    end

    always @(posedge clk_b) begin
        if(en_b) begin
            if(we_b) mem[addr_b] <= din_b; // write
            else dout_b <= mem[addr_b]; // read
        end
    end

endmodule