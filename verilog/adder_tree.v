/* Seven stage PIPELINED Bfloat16 adder tree */

module adder_tree#(
    parameter DATA_WIDTH = 16,
    parameter ARRAY_SIZE = 128
)(
    input clk,
    input rst_n,
    input [(DATA_WIDTH*ARRAY_SIZE)-1:0] PE_result, // FF register will be inserted at top module for pipeline
    output reg [DATA_WIDTH-1:0] layer7_out_reg 
);

localparam PE_RESULT_WIDTH = (DATA_WIDTH*ARRAY_SIZE);
localparam Layer1_WIDTH = (DATA_WIDTH*64);
localparam Layer2_WIDTH = (DATA_WIDTH*32);
localparam Layer3_WIDTH = (DATA_WIDTH*16);
localparam Layer4_WIDTH = (DATA_WIDTH*8);
localparam Layer5_WIDTH = (DATA_WIDTH*4);
localparam Layer6_WIDTH = (DATA_WIDTH*2);

// reg can be synthesis both latch(level triggered) and FF(clk edge triggered)

wire [Layer1_WIDTH-1:0] layer1_out_wire;
wire [Layer2_WIDTH-1:0] layer2_out_wire;
wire [Layer3_WIDTH-1:0] layer3_out_wire;
wire [Layer4_WIDTH-1:0] layer4_out_wire;
wire [Layer5_WIDTH-1:0] layer5_out_wire;
wire [Layer6_WIDTH-1:0] layer6_out_wire;
wire [DATA_WIDTH-1:0] layer7_out_wire;

reg [(DATA_WIDTH*ARRAY_SIZE)-1:0] PE_result_reg;


///////////////////////////////////// Layer1 /////////////////////////////////////

genvar i;
generate
    for (i = 0; i < 128; i = i + 2) begin : BF_adder_Layer1
        BF_adder Layer1 (PE_result_reg[(PE_RESULT_WIDTH - 1 - DATA_WIDTH*i) : (PE_RESULT_WIDTH - DATA_WIDTH*(i+1))],  
        PE_result_reg[(PE_RESULT_WIDTH - 1 - DATA_WIDTH*(i+1)) : (PE_RESULT_WIDTH - DATA_WIDTH*(i+2))], 
        layer1_out_wire[(Layer1_WIDTH - 1 - DATA_WIDTH*(i/2)) : (Layer1_WIDTH - DATA_WIDTH*(i/2 + 1))]);
    end
endgenerate

reg [Layer1_WIDTH-1:0] layer1_out_reg; // FF

///////////////////////////////////// Layer2 /////////////////////////////////////

generate
    for (i = 0; i < 64; i = i + 2) begin : BF_adder_Layer2
        BF_adder Layer2 (layer1_out_reg[(Layer1_WIDTH - 1 - DATA_WIDTH*i) : (Layer1_WIDTH - DATA_WIDTH*(i+1))],  
        layer1_out_reg[(Layer1_WIDTH - 1 - DATA_WIDTH*(i+1)) : (Layer1_WIDTH - DATA_WIDTH*(i+2))], 
        layer2_out_wire[(Layer2_WIDTH - 1 - DATA_WIDTH*(i/2)) : (Layer2_WIDTH - DATA_WIDTH*(i/2 + 1))]);
    end
endgenerate

reg [Layer2_WIDTH-1:0] layer2_out_reg; // FF

///////////////////////////////////// Layer3 /////////////////////////////////////

generate
    for (i = 0; i < 32; i = i + 2) begin : BF_adder_Layer3
        BF_adder Layer3 (layer2_out_reg[(Layer2_WIDTH - 1 - DATA_WIDTH*i) : (Layer2_WIDTH - DATA_WIDTH*(i+1))],  
        layer2_out_reg[(Layer2_WIDTH - 1 - DATA_WIDTH*(i+1)) : (Layer2_WIDTH - DATA_WIDTH*(i+2))], 
        layer3_out_wire[(Layer3_WIDTH - 1 - DATA_WIDTH*(i/2)) : (Layer3_WIDTH - DATA_WIDTH*(i/2 + 1))]);
    end
endgenerate

reg [Layer3_WIDTH-1:0] layer3_out_reg; // FF

///////////////////////////////////// Layer4 /////////////////////////////////////

generate
    for (i = 0; i < 16; i = i + 2) begin : BF_adder_Layer4
        BF_adder Layer4 (layer3_out_reg[(Layer3_WIDTH - 1 - DATA_WIDTH*i) : (Layer3_WIDTH - DATA_WIDTH*(i+1))],  
        layer3_out_reg[(Layer3_WIDTH - 1 - DATA_WIDTH*(i+1)) : (Layer3_WIDTH - DATA_WIDTH*(i+2))], 
        layer4_out_wire[(Layer4_WIDTH - 1 - DATA_WIDTH*(i/2)) : (Layer4_WIDTH - DATA_WIDTH*(i/2 + 1))]);
    end
endgenerate

reg [Layer4_WIDTH-1:0] layer4_out_reg; // FF

///////////////////////////////////// Layer5 /////////////////////////////////////

generate
    for (i = 0; i < 8; i = i + 2) begin : BF_adder_Layer5
        BF_adder Layer5 (layer4_out_reg[(Layer4_WIDTH - 1 - DATA_WIDTH*i) : (Layer4_WIDTH - DATA_WIDTH*(i+1))],  
        layer4_out_reg[(Layer4_WIDTH - 1 - DATA_WIDTH*(i+1)) : (Layer4_WIDTH - DATA_WIDTH*(i+2))], 
        layer5_out_wire[(Layer5_WIDTH - 1 - DATA_WIDTH*(i/2)) : (Layer5_WIDTH - DATA_WIDTH*(i/2 + 1))]);
    end
endgenerate

reg [Layer5_WIDTH-1:0] layer5_out_reg; // FF

///////////////////////////////////// Layer6 /////////////////////////////////////

BF_adder BF_adder_Layer6_0 (layer5_out_reg[(Layer5_WIDTH - 1) : (Layer5_WIDTH - DATA_WIDTH)], 
                            layer5_out_reg[(Layer5_WIDTH - 1 - DATA_WIDTH) : (Layer5_WIDTH - DATA_WIDTH*2)], layer6_out_wire[Layer6_WIDTH - 1 : DATA_WIDTH]);

BF_adder BF_adder_Layer6_1 (layer5_out_reg[(Layer5_WIDTH - 1 - DATA_WIDTH*2) : (Layer5_WIDTH - DATA_WIDTH*3)], 
                            layer5_out_reg[(Layer5_WIDTH - 1 - DATA_WIDTH*3) : (Layer5_WIDTH - DATA_WIDTH*4)], layer6_out_wire[DATA_WIDTH - 1 : 0]);

reg [Layer6_WIDTH-1:0] layer6_out_reg;

///////////////////////////////////// Layer7 /////////////////////////////////////


BF_adder BF_adder_Layer7 (layer6_out_reg[(Layer6_WIDTH - 1) : (Layer6_WIDTH - DATA_WIDTH)], 
                            layer6_out_reg[(Layer6_WIDTH - 1 - DATA_WIDTH) : (Layer6_WIDTH - DATA_WIDTH*2)], layer7_out_wire[DATA_WIDTH-1:0]);


///////////////////////////////////// PIPELINING /////////////////////////////////////

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) PE_result_reg <= 0;
    else PE_result_reg <= PE_result;
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) layer1_out_reg <= 0;
    else layer1_out_reg <= layer1_out_wire;
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) layer2_out_reg <= 0;
    else layer2_out_reg <= layer2_out_wire;
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) layer3_out_reg <= 0;
    else layer3_out_reg <= layer3_out_wire;
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) layer4_out_reg <= 0;
    else layer4_out_reg <= layer4_out_wire;
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) layer5_out_reg <= 0;
    else layer5_out_reg <= layer5_out_wire;
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) layer6_out_reg <= 0;
    else layer6_out_reg <= layer6_out_wire;
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) layer7_out_reg <= 0;
    else layer7_out_reg <= layer7_out_wire;
end


endmodule