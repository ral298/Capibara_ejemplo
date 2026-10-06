`timescale 1ns/1ps

// Time-multiplexed signed INT8 fully connected layer.
// Interface: start/busy/done, combinational activation/weight/bias reads, and
// a registered signed INT32 logit write stream.
// Latency: one mac_unit request at a time plus bias and write cycles.
// Signedness: activations/weights are INT8; accumulators, biases, logits INT32.
//
// State transition table:
// IDLE      : start_i ? ISSUE_MAC : IDLE
// ISSUE_MAC : unconditionally WAIT_MAC
// WAIT_MAC  : final input ? ADD_BIAS : ISSUE_MAC
// ADD_BIAS  : unconditionally WRITE
// WRITE     : final output ? IDLE : ISSUE_MAC
module fully_connected #(
    parameter int IN_FEATURES = 16,
    parameter int OUT_FEATURES = 10,
    parameter int ACT_W = 8,
    parameter int WGT_W = 8,
    parameter int ACC_W = 32,
    parameter int ADDR_W = 24,
    parameter int COUNT_W = 16
) (
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic                         start_i,
    output logic                         busy_o,
    output logic                         done_o,
    output logic                         activation_read_en_o,
    output logic [ADDR_W-1:0]            activation_read_addr_o,
    input  logic signed [ACT_W-1:0]      activation_read_data_i,
    output logic                         weight_read_en_o,
    output logic [ADDR_W-1:0]            weight_read_addr_o,
    input  logic signed [WGT_W-1:0]      weight_read_data_i,
    output logic                         bias_read_en_o,
    output logic [ADDR_W-1:0]            bias_read_addr_o,
    input  logic signed [ACC_W-1:0]      bias_read_data_i,
    output logic                         output_valid_o,
    output logic [ADDR_W-1:0]            output_write_addr_o,
    output logic signed [ACC_W-1:0]      output_data_o
);

    typedef enum logic [2:0] {
        STATE_IDLE,
        STATE_ISSUE_MAC,
        STATE_WAIT_MAC,
        STATE_ADD_BIAS,
        STATE_WRITE
    } state_t;

    state_t state_q;
    logic [COUNT_W-1:0] input_index_q;
    logic [COUNT_W-1:0] output_index_q;
    logic [ADDR_W-1:0] weight_index_q;
    logic signed [ACC_W-1:0] accumulator_q;
    logic signed [ACC_W-1:0] biased_accumulator_q;
    logic signed [ACC_W:0] bias_sum_extended_comb;
    logic mac_valid_i;
    logic mac_valid_o;
    logic signed [ACC_W-1:0] mac_acc_o;

    mac_unit #(
        .ACT_W(ACT_W),
        .WGT_W(WGT_W),
        .ACC_W(ACC_W)
    ) u_mac_unit (
        .clk      (clk),
        .rst_n    (rst_n),
        .valid_i  (mac_valid_i),
        .act_i    (activation_read_data_i),
        .weight_i (weight_read_data_i),
        .acc_i    (accumulator_q),
        .valid_o  (mac_valid_o),
        .acc_o    (mac_acc_o)
    );

    always_comb begin
        activation_read_en_o = (state_q == STATE_ISSUE_MAC);
        activation_read_addr_o = input_index_q;
        weight_read_en_o = (state_q == STATE_ISSUE_MAC);
        weight_read_addr_o = weight_index_q;
        bias_read_en_o = (state_q == STATE_ADD_BIAS);
        bias_read_addr_o = output_index_q;
        mac_valid_i = (state_q == STATE_ISSUE_MAC);
        bias_sum_extended_comb =
            $signed({accumulator_q[ACC_W-1], accumulator_q})
          + $signed({bias_read_data_i[ACC_W-1], bias_read_data_i});
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_q <= STATE_IDLE;
            busy_o <= 1'b0;
            done_o <= 1'b0;
            output_valid_o <= 1'b0;
            output_write_addr_o <= '0;
            output_data_o <= '0;
            input_index_q <= '0;
            output_index_q <= '0;
            weight_index_q <= '0;
            accumulator_q <= '0;
            biased_accumulator_q <= '0;
        end else begin
            done_o <= 1'b0;
            output_valid_o <= 1'b0;
            case (state_q)
                STATE_IDLE: begin
                    busy_o <= 1'b0;
                    if (start_i) begin
                        busy_o <= 1'b1;
                        input_index_q <= '0;
                        output_index_q <= '0;
                        weight_index_q <= '0;
                        accumulator_q <= '0;
                        biased_accumulator_q <= '0;
                        state_q <= STATE_ISSUE_MAC;
                    end
                end

                STATE_ISSUE_MAC: begin
                    state_q <= STATE_WAIT_MAC;
                end

                STATE_WAIT_MAC: begin
                    if (mac_valid_o) begin
                        accumulator_q <= mac_acc_o;
                        if (input_index_q == IN_FEATURES - 1) begin
                            input_index_q <= '0;
                            state_q <= STATE_ADD_BIAS;
                        end else begin
                            input_index_q <= input_index_q + 1'b1;
                            weight_index_q <= weight_index_q + 1'b1;
                            state_q <= STATE_ISSUE_MAC;
                        end
                    end
                end

                STATE_ADD_BIAS: begin
                    biased_accumulator_q <=
                        bias_sum_extended_comb[ACC_W-1:0];
                    state_q <= STATE_WRITE;
                end

                STATE_WRITE: begin
                    output_valid_o <= 1'b1;
                    output_write_addr_o <= output_index_q;
                    output_data_o <= biased_accumulator_q;
                    accumulator_q <= '0;
                    biased_accumulator_q <= '0;
                    if (output_index_q == OUT_FEATURES - 1) begin
                        output_index_q <= '0;
                        busy_o <= 1'b0;
                        done_o <= 1'b1;
                        state_q <= STATE_IDLE;
                    end else begin
                        output_index_q <= output_index_q + 1'b1;
                        weight_index_q <= weight_index_q + 1'b1;
                        state_q <= STATE_ISSUE_MAC;
                    end
                end

                default: begin
                    state_q <= STATE_IDLE;
                    busy_o <= 1'b0;
                    done_o <= 1'b0;
                    output_valid_o <= 1'b0;
                end
            endcase
        end
    end

endmodule
