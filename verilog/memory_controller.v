module memory_controller(
    input clk,
    input rst_n,
    input start,

    output we_A, we_B, we_out,
    output en_A, en_B, en_out,
    output [5:0] addr_a, addr_b,
    output reg [11:0] addr_out,
    output done
);

localparam IDLE = 2'b00, 
           A_LOAD = 2'b01,
           A_STOP = 2'b10,
           DONE = 2'b11;

reg [1:0] state, next_state;
reg [3:0] counter_a_stop;
reg [3:0] counter_done;
reg [6:0] addr_a_reg, addr_b_reg;

assign addr_a = addr_a_reg[5:0];
assign addr_b = addr_b_reg[5:0];

 always @(*) begin
    case(state)
        IDLE : begin
            if(start && !done) next_state = A_LOAD;
            else next_state = IDLE;
        end
        A_LOAD : begin
            next_state = A_STOP; // During 1 clk, read the first data of each of A and B and start the operation by going to A_STOP.
        end
        A_STOP : begin
            if(addr_a_reg == 7'd64 && addr_b_reg == 7'd63) next_state = DONE;
            // read data during state transition at addr_a_reg == 64 and addr_b_reg == 63
            // <=> If it is the last row of A and the last column of B, read the data and move to DONE on the next clk.
            else if(addr_a_reg != 7'd64 && addr_b_reg == 7'd63) next_state = A_LOAD;
            // If A is not yet the last row, when B reaches the last column, it takes the data and goes back to loading A (with a state transition clk).
            else next_state = A_STOP;
            // Otherwise, keep the operation
        end
        DONE : begin
            if(counter_done == 4'd8) next_state = IDLE; 
            // Waits until the last data read from A_STOP reaches the buffer.
            // Reading from state transition clk and calculating for 8 clk during DONE + writing takes 1 clk (during done -> idle state transition)
            // In IDLE, turning off all signals. dout <= mem reg will still consume power?
            else next_state = DONE; 
        end
        default : next_state = next_state;
    endcase
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) state <= IDLE;
    else state <= next_state;
end


//////////////// enable signals ////////////////

assign en_A = (state == A_LOAD) ? 1'b1 : 1'b0; // A is read only during A_lOAD, and even if the signal is turned off in A_STOP, it is stored in the dout register of the input mem.
assign en_B = (state == A_LOAD || state == A_STOP) ? 1'b1 : 1'b0; // B must always be read in the two preceding states
assign we_A = 1'b0; // No write
assign we_B = 1'b0; // No write

assign en_out = (state == A_LOAD || state == A_STOP || state == DONE) ? ((counter_a_stop == 4'd8) ? 1'b1 : 1'b0) : 1'b0;
// From the second row of A, operations and output writing continue even in the A_LOAD state, and the conditional statement back side means waits for 8 clk at the initial A_STOP.
assign we_out = (state == A_LOAD || state == A_STOP || state == DONE) ? ((counter_a_stop == 4'd8) ? 1'b1 : 1'b0) : 1'b0;
// Same as above
assign done = (counter_done == 4'd9) ? 1'b1 : 1'b0;
// Waiting for the last data is saved after entering the DONE state, and maintained done signal to HIGH even when returning to IDLE.

//////////////// address change ////////////////

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) addr_a_reg <= 7'd0; // for IDLE
    else if(state == A_LOAD) addr_a_reg <= addr_a_reg + 7'd1; // Increases by 1 when A_LOAD ends, max value is 64.
    else addr_a_reg <= addr_a_reg; // for A_STOP, DONE, address is not initialized separately.
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) addr_b_reg <= 7'd0; // for IDLE
    else if(state == A_LOAD) addr_b_reg <= addr_b_reg + 7'd1; // addr_b_reg = 0
    else if(state == A_STOP) begin
        if(addr_a_reg != 7'd64 && addr_b_reg == 7'd63) addr_b_reg <= 7'd0; // Before going back to A_LOAD, addr_b_reg : max value is 63.
        else if(addr_a_reg == 7'd64 && addr_b_reg == 7'd63) addr_b_reg <= addr_b_reg; // Before going to DONE.
        else addr_b_reg <= addr_b_reg + 7'd1;
    end
    else addr_b_reg <= addr_b_reg; // for DONE
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) addr_out <= 12'd0;
    else if(state == A_STOP || state == A_LOAD || state == DONE) begin
        if(counter_a_stop == 4'd8 && addr_out != 12'd4095) addr_out <= addr_out + 12'd1; 
        // wait first 8 clks, max 4095, doesn't increase during DONE -> IDLE.
        else addr_out <= addr_out; // before first 8 clks
    end
    else addr_out <= addr_out; // for DONE
end

//////////////// required counters ////////////////

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) counter_a_stop <= 4'd0; // IDLE
    else if(state == A_STOP && counter_a_stop != 4'd8) counter_a_stop <= counter_a_stop + 4'd1; // activate only at first A_STOP
    else counter_a_stop <= counter_a_stop; // remain as 8
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) counter_done <= 4'd0;
    else if(state == DONE && counter_done != 4'd9) counter_done <= counter_done + 4'd1;
    else counter_done <= counter_done;
end

endmodule