`timescale 1ns/1ps

// Exact signed multiply-accumulate implementation.
// Interface: accepts signed activation, weight, and accumulator with valid_i.
// Latency: one cycle; an input accepted on edge N is valid during cycle N+1.
// Signedness: product is ACT_W+WGT_W bits and is explicitly sign-extended.
module exact_mac #(
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

    localparam int PROD_W = ACT_W + WGT_W;

    logic signed [PROD_W-1:0] act_extended_comb;
    logic signed [PROD_W-1:0] weight_extended_comb;
    logic signed [PROD_W-1:0] product_comb;
    logic signed [ACC_W-1:0] product_acc_comb;
    logic signed [ACC_W:0] sum_extended_comb;

    always_comb begin
        act_extended_comb = {
            {(PROD_W-ACT_W){act_i[ACT_W-1]}},
            act_i
        };
        weight_extended_comb = {
            {(PROD_W-WGT_W){weight_i[WGT_W-1]}},
            weight_i
        };
        product_comb = $signed(act_extended_comb) * $signed(weight_extended_comb);
        product_acc_comb = {
            {(ACC_W-PROD_W){product_comb[PROD_W-1]}},
            product_comb
        };
        sum_extended_comb = $signed({acc_i[ACC_W-1], acc_i})
                          + $signed({
                              product_acc_comb[ACC_W-1],
                              product_acc_comb
                          });
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_o <= 1'b0;
            acc_o   <= '0;
        end else begin
            valid_o <= valid_i;
            if (valid_i) begin
                // Truncating to ACC_W implements specified two's-complement wrap.
                acc_o <= sum_extended_comb[ACC_W-1:0];
            end else begin
                acc_o <= '0;
            end
        end
    end

endmodule
