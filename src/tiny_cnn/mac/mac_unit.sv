`timescale 1ns/1ps

// Stable MAC abstraction used by convolution and fully connected consumers.
// Interface: exactly matches the project-level mac_unit contract.
// Latency: one cycle through the selected exact_mac baseline.
// Signedness: activation, weight, accumulator, and result are explicitly signed.
module mac_unit #(
    parameter int ACT_W = 8,
    parameter int WGT_W = 8,
    parameter int ACC_W = 32
) (
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic                         valid_i,
    input  logic signed [ACT_W-1:0]      act_i,
    input  logic signed [WGT_W-1:0]      weight_i,
    input  logic signed [ACC_W-1:0]      acc_i,
    output logic                         valid_o,
    output logic signed [ACC_W-1:0]      acc_o
);

    exact_mac #(
        .ACT_W(ACT_W),
        .WGT_W(WGT_W),
        .ACC_W(ACC_W)
    ) u_exact_mac (
        .clk      (clk),
        .rst_n    (rst_n),
        .valid_i  (valid_i),
        .act_i    (act_i),
        .weight_i (weight_i),
        .acc_i    (acc_i),
        .valid_o  (valid_o),
        .acc_o    (acc_o)
    );

endmodule
