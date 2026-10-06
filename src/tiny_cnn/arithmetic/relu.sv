`timescale 1ns/1ps

// Signed ReLU.
// Interface: one signed DATA_W input and one signed DATA_W output.
// Latency: zero cycles; this module is purely combinational.
// Signedness: the sign bit determines whether the result is zero.
module relu #(
    parameter int DATA_W = 8
) (
    input  logic signed [DATA_W-1:0] value_i,
    output logic signed [DATA_W-1:0] value_o
);

    always_comb begin
        if (value_i[DATA_W-1]) begin
            value_o = '0;
        end else begin
            value_o = value_i;
        end
    end

endmodule
