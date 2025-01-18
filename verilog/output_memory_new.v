// Dual port memory

module output_memory#(
    parameter DATA_WIDTH = 16, // each row of A, each col of B
    parameter ADDR_WIDTH_PL = 12, // log2(64*64=2^12)
    parameter ADDR_WIDTH_PS = 6  // log2(64) = 6
)(
    input clk,
    input en_a, en_b, // chip enable
    input we_a, we_b,
    input [ADDR_WIDTH_PS-1:0] addr_a,
    input [ADDR_WIDTH_PL-1:0] addr_b,
    input [DATA_WIDTH*64-1:0] din_a, // write one row (64 datas) at once
    input [DATA_WIDTH-1:0] din_b, // write one by one
    output reg [DATA_WIDTH*64-1:0] dout_a, // FF but synthesis as bram resource
    output reg [DATA_WIDTH-1:0] dout_b 
);

    (* ram_style = "block" *) reg [DATA_WIDTH*64-1:0] mem [(1<<ADDR_WIDTH_PS)-1:0]; // depth 64

    // Port A logic (Row-wise access)
    always @(posedge clk) begin
        if(en_a) begin
            if(we_a)
                mem[addr_a] <= din_a; // write entire row
            else
                dout_a <= mem[addr_a]; // read entire row
        end
    end

    // Port B logic (Element-wise access)
    always @(posedge clk) begin
        if(en_b) begin
            if(we_b) 
                mem[addr_b / DATA_WIDTH][] <= din_b; // write one element
            else 
                dout_b <= mem[addr_b[ADDR_WIDTH_PS-1:0]][DATA_WIDTH*(addr_b[ADDR_WIDTH_PL-ADDR_WIDTH_PS-1:0]+1)-1 -: DATA_WIDTH]; // read one element
        end
    end

    //addr_b[ADDR_WIDTH_PS-1:0] selects the row.
    //addr_b[ADDR_WIDTH_PL-ADDR_WIDTH_PS-1:0] selects the column within the row.

endmodule