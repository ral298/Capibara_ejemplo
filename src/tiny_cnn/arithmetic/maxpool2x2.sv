`timescale 1ns/1ps

// Signed maximum over one 2-by-2 pooling window.
// Interface: four signed DATA_W samples and one signed DATA_W maximum.
// Latency: zero cycles; this module is purely combinational.
// Signedness: every comparison is explicitly signed.
module maxpool2x2 #(
    parameter int DATA_W = 8
) (
    input  logic signed [DATA_W-1:0] sample_0_i,
    input  logic signed [DATA_W-1:0] sample_1_i,
    input  logic signed [DATA_W-1:0] sample_2_i,
    input  logic signed [DATA_W-1:0] sample_3_i,
    output logic signed [DATA_W-1:0] maximum_o
);

    logic signed [DATA_W-1:0] maximum_01_comb;
    logic signed [DATA_W-1:0] maximum_23_comb;

    always_comb begin
        if ($signed(sample_0_i) >= $signed(sample_1_i)) begin
            maximum_01_comb = sample_0_i;
        end else begin
            maximum_01_comb = sample_1_i;
        end

        if ($signed(sample_2_i) >= $signed(sample_3_i)) begin
            maximum_23_comb = sample_2_i;
        end else begin
            maximum_23_comb = sample_3_i;
        end

        if ($signed(maximum_01_comb) >= $signed(maximum_23_comb)) begin
            maximum_o = maximum_01_comb;
        end else begin
            maximum_o = maximum_23_comb;
        end
    end

endmodule
