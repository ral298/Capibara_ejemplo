`timescale 1ns/1ps

// Safe address presentation for the generic stride-one 3x3 convolution.
// Interface: loop counters and incrementally tracked indices in; clamped
// activation, weight, bias, and output addresses out.
// Latency: zero cycles; all outputs are combinational.
// Signedness: spatial coordinates and the candidate activation address are
// signed so negative padding positions cannot become memory accesses.
//
// The convolution engine incrementally tracks the linear HWC/OHWI indices.
// This block independently evaluates spatial validity. An invalid padded
// coordinate forces activation_address_o to zero and input_in_range_o low.
module address_generator #(
    parameter int COUNT_W = 16,
    parameter int ADDR_W = 24
) (
    input  logic [COUNT_W-1:0] input_height_i,
    input  logic [COUNT_W-1:0] input_width_i,
    input  logic [COUNT_W-1:0] padding_i,
    input  logic [COUNT_W-1:0] output_row_i,
    input  logic [COUNT_W-1:0] output_column_i,
    input  logic [COUNT_W-1:0] output_channel_i,
    input  logic [COUNT_W-1:0] kernel_row_i,
    input  logic [COUNT_W-1:0] kernel_column_i,
    input  logic signed [ADDR_W:0] activation_candidate_i,
    input  logic [ADDR_W-1:0] weight_index_i,
    input  logic [ADDR_W-1:0] output_index_i,
    output logic input_in_range_o,
    output logic [ADDR_W-1:0] activation_address_o,
    output logic [ADDR_W-1:0] weight_address_o,
    output logic [ADDR_W-1:0] bias_address_o,
    output logic [ADDR_W-1:0] output_address_o
);

    logic signed [COUNT_W:0] input_row_signed_comb;
    logic signed [COUNT_W:0] input_column_signed_comb;

    always_comb begin
        input_row_signed_comb = $signed({1'b0, output_row_i})
                              + $signed({1'b0, kernel_row_i})
                              - $signed({1'b0, padding_i});
        input_column_signed_comb = $signed({1'b0, output_column_i})
                                 + $signed({1'b0, kernel_column_i})
                                 - $signed({1'b0, padding_i});

        input_in_range_o = !input_row_signed_comb[COUNT_W]
                         && !input_column_signed_comb[COUNT_W]
                         && ($signed(input_row_signed_comb)
                             < $signed({1'b0, input_height_i}))
                         && ($signed(input_column_signed_comb)
                             < $signed({1'b0, input_width_i}));

        if (input_in_range_o) begin
            activation_address_o = activation_candidate_i[ADDR_W-1:0];
        end else begin
            activation_address_o = '0;
        end

        weight_address_o = weight_index_i;
        bias_address_o = '0;
        bias_address_o[COUNT_W-1:0] = output_channel_i;
        output_address_o = output_index_i;
    end

endmodule
