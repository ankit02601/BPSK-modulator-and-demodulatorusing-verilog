
module BPSK (
    input clk,
    input reset,
    input bit_in,
    input signed [15:0] carrier,
    output reg signed [15:0] bpsk_out,
    output reg bit_out
);

// Internal signals
reg signed [15:0] modulated_signal;
reg signed [47:0] accumulated_signal;
reg [7:0] sample_counter;
reg signed [15:0] delayed_bpsk_out;
reg signed [15:0] delayed_carrier;

parameter BIT_PERIOD = 4;
parameter signed [47:0] THRESHOLD = 1000;

// Modulation
always @(posedge clk or posedge reset) begin
    if (reset) begin
        modulated_signal <= 0;
        bpsk_out <= 0;
    end else begin
        modulated_signal <= bit_in ? carrier : -carrier;
        bpsk_out <= modulated_signal;
    end
end

// Delay bpsk_out and carrier to align timing in demodulation
always @(posedge clk or posedge reset) begin
    if (reset) begin
        delayed_bpsk_out <= 0;
        delayed_carrier <= 0;
    end else begin
        delayed_bpsk_out <= bpsk_out;
        delayed_carrier <= carrier;
    end
end

// Demodulation
always @(posedge clk or posedge reset) begin
    if (reset) begin
        accumulated_signal <= 0;
        sample_counter <= 0;
        bit_out <= 0;
    end else begin
        // Multiply delayed signals for demodulation
         if(bpsk_out== carrier)
        accumulated_signal <= accumulated_signal + (delayed_bpsk_out * delayed_carrier);
        else 
        accumulated_signal <= accumulated_signal + (delayed_bpsk_out *(- delayed_carrier));
        // Increment the sample counter
        if (sample_counter == BIT_PERIOD - 1) begin
            // Decision making at the end of bit period using threshold
            if (accumulated_signal > THRESHOLD) begin
                bit_out <= 1;
            end else if (accumulated_signal < -THRESHOLD) begin
                bit_out <= 0;
            end
            
            // Reset for next bit period
            accumulated_signal <= 0;
            sample_counter <= 0;
        end else begin
            sample_counter <= sample_counter + 1;
        end
    end
end

endmodule