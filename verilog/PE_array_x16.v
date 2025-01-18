module PE_array_x16#(
    parameter DATA_WIDTH = 16,
    parameter ROW_SIZE = 16
)(
    input [(DATA_WIDTH*ROW_SIZE)-1:0] A,
    input [(DATA_WIDTH*ROW_SIZE)-1:0] B,
    output [(DATA_WIDTH*ROW_SIZE)-1:0] Mul
);

localparam INPUT_WIDTH = DATA_WIDTH*ROW_SIZE;

    genvar i;
    generate
        for (i = 0; i < ROW_SIZE; i = i + 1) begin : PE_col
            BF_multiplier multi(A[INPUT_WIDTH - 1 - DATA_WIDTH*i : INPUT_WIDTH - DATA_WIDTH*(i+1)], 
            B[INPUT_WIDTH - 1 - DATA_WIDTH*i : INPUT_WIDTH - DATA_WIDTH*(i+1)],
            Mul[INPUT_WIDTH - 1 - DATA_WIDTH*i : INPUT_WIDTH - DATA_WIDTH*(i+1)]); // MSB -> LSB
        end
    endgenerate

endmodule