`timescale 1ns/1ps

// Lowest-index argmax over signed values.
// Interface: NUM_VALUES signed DATA_W inputs, winning index, and winning value.
// Latency: zero cycles; this module is purely combinational.
// Signedness: candidates and the current maximum are explicitly signed.
module argmax #(
    parameter int NUM_VALUES = 10,
    parameter int DATA_W = 32,
    parameter int INDEX_W = (NUM_VALUES <= 1) ? 1 : $clog2(NUM_VALUES)
) (
    input  logic signed [DATA_W-1:0] values_i [0:NUM_VALUES-1],
    output logic        [INDEX_W-1:0] index_o,
    output logic signed [DATA_W-1:0] maximum_o
);

    integer value_index;

    always_comb begin
        index_o   = '0;
        maximum_o = values_i[0];
        for (value_index = 1; value_index < NUM_VALUES;
             value_index = value_index + 1) begin
            if ($signed(values_i[value_index]) > $signed(maximum_o)) begin
                index_o   = value_index[INDEX_W-1:0];
                maximum_o = values_i[value_index];
            end
        end
    end

endmodule
