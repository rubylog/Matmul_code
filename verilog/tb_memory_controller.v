`timescale 1ns / 1ps

module top_control_tb;

    // Inputs
    reg clk;
    reg rst_n;
    reg start;

    // Outputs
    wire we_A;
    wire we_B;
    wire we_out;
    wire en_A;
    wire en_B;
    wire en_out;
    wire [5:0] addr_a;
    wire [5:0] addr_b;
    wire [11:0] addr_out;
    wire done;

    // Instantiate the Unit Under Test (UUT)
    memory_controller uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .we_A(we_A),
        .we_B(we_B),
        .we_out(we_out),
        .en_A(en_A),
        .en_B(en_B),
        .en_out(en_out),
        .addr_a(addr_a),
        .addr_b(addr_b),
        .addr_out(addr_out),
        .done(done)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period clock
    end

    // Stimulus generation
    initial begin
        // Initialize inputs
        rst_n = 0;
        start = 0;

        // Apply reset
        #20;
        rst_n = 1;

        // Start signal
        #10;
        start = 1;
        #10;
        start = 0;

        // Wait for the done signal
        wait(done);

        // Observe final state
        #20;

    end

    // Monitor signals
    initial begin
        $monitor("Time=%0t | clk=%b | rst_n=%b | start=%b | addr_a=%d | addr_b=%d | addr_out=%d | done=%b", 
                 $time, clk, rst_n, start, addr_a, addr_b, addr_out, done);
    end

endmodule
