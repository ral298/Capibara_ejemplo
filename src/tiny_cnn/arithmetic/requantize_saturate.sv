`timescale 1ns/1ps

// Arithmetic right-shift requantization followed by signed saturation.
// Interface: signed ACC_W input, runtime shift, and signed OUT_W output.
// Latency: zero cycles; this module is purely combinational.
// Signedness: shift, limits, extensions, comparisons, and output are explicit.
module requantize_saturate #(
    parameter int ACC_W = 32,
    parameter int OUT_W = 8,
    parameter int SHIFT_W = 5
) (
    input  logic signed [ACC_W-1:0] value_i,
    input  logic        [SHIFT_W-1:0] shift_i,
    output logic signed [OUT_W-1:0] value_o
);

    localparam logic signed [OUT_W-1:0] OUTPUT_MAX = {
        1'b0,
        {(OUT_W-1){1'b1}}
    };
    localparam logic signed [OUT_W-1:0] OUTPUT_MIN = {
        1'b1,
        {(OUT_W-1){1'b0}}
    };

    logic signed [ACC_W-1:0] shifted_comb;
    logic signed [ACC_W-1:0] maximum_extended_comb;
    logic signed [ACC_W-1:0] minimum_extended_comb;

    always_comb begin
        shifted_comb = $signed(value_i) >>> shift_i;
        maximum_extended_comb = {
            {(ACC_W-OUT_W){OUTPUT_MAX[OUT_W-1]}},
            OUTPUT_MAX
        };
        minimum_extended_comb = {
            {(ACC_W-OUT_W){OUTPUT_MIN[OUT_W-1]}},
            OUTPUT_MIN
        };

        if ($signed(shifted_comb) > $signed(maximum_extended_comb)) begin
            value_o = OUTPUT_MAX;
        end else if ($signed(shifted_comb) < $signed(minimum_extended_comb)) begin
            value_o = OUTPUT_MIN;
        end else begin
            value_o = shifted_comb[OUT_W-1:0];
        end
    end

endmodule
