module PE_array_top#(
    parameter DATA_WIDTH = 16,
    parameter ARRAY_SIZE = 128,
    parameter ROW_SIZE = 16
)(
    input [(DATA_WIDTH*ARRAY_SIZE)-1:0] A,
    input [(DATA_WIDTH*ARRAY_SIZE)-1:0] B,
    output [(DATA_WIDTH*ARRAY_SIZE)-1:0] Mul
);

    localparam NUM_ROWS = ARRAY_SIZE / ROW_SIZE; // 8 rows
    localparam INPUT_WIDTH = DATA_WIDTH * ARRAY_SIZE;

    genvar i;
    generate
        for(i = 0; i < NUM_ROWS; i = i + 1) begin : PE_row
            PE_array_x16 #(
                .DATA_WIDTH(DATA_WIDTH),
                .ROW_SIZE(ROW_SIZE)
            ) pe_x16 (
                A[INPUT_WIDTH - 1 - DATA_WIDTH*ROW_SIZE*i : INPUT_WIDTH - DATA_WIDTH*ROW_SIZE*(i+1)],
                B[INPUT_WIDTH - 1 - DATA_WIDTH*ROW_SIZE*i : INPUT_WIDTH - DATA_WIDTH*ROW_SIZE*(i+1)],
                Mul[INPUT_WIDTH - 1 - DATA_WIDTH*ROW_SIZE*i : INPUT_WIDTH - DATA_WIDTH*ROW_SIZE*(i+1)]
            );
        end
    endgenerate

endmodule