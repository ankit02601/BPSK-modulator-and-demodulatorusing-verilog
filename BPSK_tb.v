
`timescale 1ns / 1ps

module BPSK_tb;

// Testbench signals
reg clk;
reg reset;
reg bit_in;
reg signed [15:0] carrier;
wire signed [15:0] bpsk_out;
wire bit_out;

// Parameters for sine wave generation
parameter CARRIER_PERIOD = 8; // Number of clock cycles for one period of sine wave

// Lookup table for sine wave (8 samples)
reg signed [15:0] sine_wave [0:7];
reg [24:0] phase_accumulator; // 3-bit phase accumulator to index sine_wave

// Instantiate the BPSK module
BPSK uut (
    .clk(clk),
    .reset(reset),
    .bit_in(bit_in),
    .carrier(carrier),
    .bpsk_out(bpsk_out),
    .bit_out(bit_out)
);

// Clock generation (100 MHz)
always #1 clk = ~clk;   // Clock period of 8 ns

// Generate carrier signal (sine wave) using lookup table
always @(posedge clk) begin
    carrier <= sine_wave[phase_accumulator];
    phase_accumulator <= phase_accumulator + 1;
    if (phase_accumulator == CARRIER_PERIOD - 1)
        phase_accumulator <= 0;
end

// Initialize sine wave lookup table
initial begin
    sine_wave[0] = 16'sd0;
    sine_wave[1] = 16'sd7071;
    sine_wave[2] = 16'sd10000;
    sine_wave[3] = 16'sd7071;
    sine_wave[4] = 16'sd0;
    sine_wave[5] = -16'sd7071;
    sine_wave[6] = -16'sd10000;
    sine_wave[7] = -16'sd7071;
end

// Test vector generation
initial begin
    // Initialize signals
    clk = 0;
    reset = 1;
    bit_in = 0;
    phase_accumulator = 0;
    
    // Reset the system
    #20 reset = 0;
    
    // Hold each bit for multiple clock cycles (e.g., 8 cycles)
    #80 bit_in = 1;  // Change bit after 80 ns (8 clock cycles)
    #80 bit_in = 1;
    #80 bit_in = 0;
    #80 bit_in = 1;
    #80 bit_in = 1;
    #80 bit_in = 0;
    #80 bit_in = 1;
    #80 bit_in = 0;
    #80 bit_in = 1;
    
    // End simulation
    #180 $stop;
end

// Monitor the outputs
initial begin
    $monitor("Time: %0t | bit_in: %b | bit_out: %b | accumulated_signal: %d", 
             $time, bit_in, bit_out, uut.accumulated_signal);
end

endmodule

