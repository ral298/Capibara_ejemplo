`timescale 1ns/1ps

// Runtime-configured single-lane signed INT8 3x3, stride-one convolution.
// Interface: start/busy/done control, captured layer geometry, combinational
// memory reads, and a registered output write stream.
// Latency: one mac_unit request at a time; total latency depends on geometry.
// Signedness: activations and weights are INT8. Accumulation, bias addition,
// raw debug output, and the externally widened result are signed INT32.
//
// The row-stride and padding offsets are supplied by the caller. This avoids
// hidden address arithmetic and permits one physical engine to execute both
// fixed CNN convolution layers.
//
// State transition table:
// IDLE      : start_i ? ISSUE_MAC : IDLE
// ISSUE_MAC : unconditionally WAIT_MAC after issuing one mac_unit request
// WAIT_MAC  : valid result and final term ? ADD_BIAS
//             valid result and more terms ? ISSUE_MAC
//             no valid result ? WAIT_MAC
// ADD_BIAS  : unconditionally WRITE
// WRITE     : final output ? IDLE : ISSUE_MAC
module convolution_engine #(
    parameter int ACT_W = 8,
    parameter int WGT_W = 8,
    parameter int ACC_W = 32,
    parameter int SHIFT_W = 5,
    parameter int COUNT_W = 16,
    parameter int ADDR_W = 24
) (
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic                         start_i,
    input  logic                         requant_enable_i,
    input  logic                         relu_enable_i,
    input  logic [SHIFT_W-1:0]           shift_i,
    input  logic [COUNT_W-1:0]           input_height_i,
    input  logic [COUNT_W-1:0]           input_width_i,
    input  logic [COUNT_W-1:0]           input_channels_i,
    input  logic [COUNT_W-1:0]           output_height_i,
    input  logic [COUNT_W-1:0]           output_width_i,
    input  logic [COUNT_W-1:0]           output_channels_i,
    input  logic [COUNT_W-1:0]           padding_i,
    input  logic signed [ADDR_W:0]       input_row_stride_i,
    input  logic signed [ADDR_W:0]       kernel_row_span_i,
    input  logic signed [ADDR_W:0]       padding_total_i,
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
    output logic signed [ACC_W-1:0]      output_data_o,
    output logic signed [ACC_W-1:0]      output_raw_acc_o,
    output logic signed [ACT_W-1:0]      output_requantized_o
);

    localparam logic [COUNT_W-1:0] LAST_KERNEL_INDEX = 2;

    typedef enum logic [2:0] {
        STATE_IDLE,
        STATE_ISSUE_MAC,
        STATE_WAIT_MAC,
        STATE_ADD_BIAS,
        STATE_WRITE
    } state_t;

    state_t state_q;

    logic [COUNT_W-1:0] input_height_q;
    logic [COUNT_W-1:0] input_width_q;
    logic [COUNT_W-1:0] input_channels_q;
    logic [COUNT_W-1:0] output_height_q;
    logic [COUNT_W-1:0] output_width_q;
    logic [COUNT_W-1:0] output_channels_q;
    logic [COUNT_W-1:0] padding_q;
    logic signed [ADDR_W:0] input_row_stride_q;
    logic signed [ADDR_W:0] kernel_row_span_q;
    logic signed [ADDR_W:0] padding_total_q;

    logic [COUNT_W-1:0] output_row_q;
    logic [COUNT_W-1:0] output_column_q;
    logic [COUNT_W-1:0] output_channel_q;
    logic [COUNT_W-1:0] kernel_row_q;
    logic [COUNT_W-1:0] kernel_column_q;
    logic [COUNT_W-1:0] input_channel_q;
    logic signed [ADDR_W:0] activation_candidate_q;
    logic signed [ADDR_W:0] kernel_origin_q;
    logic signed [ADDR_W:0] output_row_base_q;
    logic [ADDR_W-1:0] weight_index_q;
    logic [ADDR_W-1:0] output_index_q;

    logic requant_enable_q;
    logic relu_enable_q;
    logic [SHIFT_W-1:0] shift_q;

    logic input_in_range_comb;
    logic [ADDR_W-1:0] activation_address_comb;
    logic [ADDR_W-1:0] weight_address_comb;
    logic [ADDR_W-1:0] bias_address_comb;
    logic [ADDR_W-1:0] output_address_comb;

    logic mac_valid_i;
    logic signed [ACT_W-1:0] mac_act_i;
    logic signed [WGT_W-1:0] mac_weight_i;
    logic signed [ACC_W-1:0] mac_acc_i;
    logic mac_valid_o;
    logic signed [ACC_W-1:0] mac_acc_o;

    logic signed [ACC_W-1:0] accumulator_q;
    logic signed [ACC_W-1:0] biased_accumulator_q;
    logic signed [ACC_W:0] bias_sum_extended_comb;

    logic signed [ACT_W-1:0] requantized_comb;
    logic signed [ACT_W-1:0] requantized_relu_comb;
    logic signed [ACC_W-1:0] raw_relu_comb;
    logic signed [ACT_W-1:0] selected_int8_comb;
    logic signed [ACC_W-1:0] final_output_comb;
    logic signed [ADDR_W:0] activation_row_jump_comb;

    address_generator #(
        .COUNT_W(COUNT_W),
        .ADDR_W(ADDR_W)
    ) u_address_generator (
        .input_height_i       (input_height_q),
        .input_width_i        (input_width_q),
        .padding_i            (padding_q),
        .output_row_i         (output_row_q),
        .output_column_i      (output_column_q),
        .output_channel_i     (output_channel_q),
        .kernel_row_i         (kernel_row_q),
        .kernel_column_i      (kernel_column_q),
        .activation_candidate_i (activation_candidate_q),
        .weight_index_i       (weight_index_q),
        .output_index_i       (output_index_q),
        .input_in_range_o     (input_in_range_comb),
        .activation_address_o (activation_address_comb),
        .weight_address_o     (weight_address_comb),
        .bias_address_o       (bias_address_comb),
        .output_address_o     (output_address_comb)
    );

    mac_unit #(
        .ACT_W(ACT_W),
        .WGT_W(WGT_W),
        .ACC_W(ACC_W)
    ) u_mac_unit (
        .clk      (clk),
        .rst_n    (rst_n),
        .valid_i  (mac_valid_i),
        .act_i    (mac_act_i),
        .weight_i (mac_weight_i),
        .acc_i    (mac_acc_i),
        .valid_o  (mac_valid_o),
        .acc_o    (mac_acc_o)
    );

    requantize_saturate #(
        .ACC_W(ACC_W),
        .OUT_W(ACT_W),
        .SHIFT_W(SHIFT_W)
    ) u_requantize_saturate (
        .value_i (biased_accumulator_q),
        .shift_i (shift_q),
        .value_o (requantized_comb)
    );

    relu #(
        .DATA_W(ACT_W)
    ) u_requantized_relu (
        .value_i (requantized_comb),
        .value_o (requantized_relu_comb)
    );

    relu #(
        .DATA_W(ACC_W)
    ) u_raw_relu (
        .value_i (biased_accumulator_q),
        .value_o (raw_relu_comb)
    );

    always_comb begin
        activation_read_addr_o = activation_address_comb;
        weight_read_addr_o = weight_address_comb;
        bias_read_addr_o = bias_address_comb;

        activation_read_en_o = 1'b0;
        weight_read_en_o = 1'b0;
        bias_read_en_o = 1'b0;

        mac_valid_i = 1'b0;
        mac_act_i = '0;
        mac_weight_i = '0;
        mac_acc_i = accumulator_q;

        if (state_q == STATE_ISSUE_MAC) begin
            weight_read_en_o = 1'b1;
            mac_weight_i = weight_read_data_i;
            if (input_in_range_comb) begin
                activation_read_en_o = 1'b1;
                mac_act_i = activation_read_data_i;
            end
            mac_valid_i = 1'b1;
        end

        if (state_q == STATE_ADD_BIAS) begin
            bias_read_en_o = 1'b1;
        end
    end

    always_comb begin
        bias_sum_extended_comb =
            $signed({accumulator_q[ACC_W-1], accumulator_q})
          + $signed({bias_read_data_i[ACC_W-1], bias_read_data_i});
        activation_row_jump_comb =
            input_row_stride_q - kernel_row_span_q + 1;

        if (relu_enable_q) begin
            selected_int8_comb = requantized_relu_comb;
        end else begin
            selected_int8_comb = requantized_comb;
        end

        if (requant_enable_q) begin
            final_output_comb = {
                {(ACC_W-ACT_W){selected_int8_comb[ACT_W-1]}},
                selected_int8_comb
            };
        end else if (relu_enable_q) begin
            final_output_comb = raw_relu_comb;
        end else begin
            final_output_comb = biased_accumulator_q;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_q <= STATE_IDLE;
            busy_o <= 1'b0;
            done_o <= 1'b0;
            output_valid_o <= 1'b0;
            output_write_addr_o <= '0;
            output_data_o <= '0;
            output_raw_acc_o <= '0;
            output_requantized_o <= '0;

            input_height_q <= '0;
            input_width_q <= '0;
            input_channels_q <= '0;
            output_height_q <= '0;
            output_width_q <= '0;
            output_channels_q <= '0;
            padding_q <= '0;
            input_row_stride_q <= '0;
            kernel_row_span_q <= '0;
            padding_total_q <= '0;

            output_row_q <= '0;
            output_column_q <= '0;
            output_channel_q <= '0;
            kernel_row_q <= '0;
            kernel_column_q <= '0;
            input_channel_q <= '0;
            activation_candidate_q <= '0;
            kernel_origin_q <= '0;
            output_row_base_q <= '0;
            weight_index_q <= '0;
            output_index_q <= '0;

            requant_enable_q <= 1'b0;
            relu_enable_q <= 1'b0;
            shift_q <= '0;
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
                        requant_enable_q <= requant_enable_i;
                        relu_enable_q <= relu_enable_i;
                        shift_q <= shift_i;
                        input_height_q <= input_height_i;
                        input_width_q <= input_width_i;
                        input_channels_q <= input_channels_i;
                        output_height_q <= output_height_i;
                        output_width_q <= output_width_i;
                        output_channels_q <= output_channels_i;
                        padding_q <= padding_i;
                        input_row_stride_q <= input_row_stride_i;
                        kernel_row_span_q <= kernel_row_span_i;
                        padding_total_q <= padding_total_i;

                        output_row_q <= '0;
                        output_column_q <= '0;
                        output_channel_q <= '0;
                        kernel_row_q <= '0;
                        kernel_column_q <= '0;
                        input_channel_q <= '0;
                        activation_candidate_q <= -padding_total_i;
                        kernel_origin_q <= -padding_total_i;
                        output_row_base_q <= '0;
                        weight_index_q <= '0;
                        output_index_q <= '0;
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
                        if (input_channel_q == input_channels_q - 1'b1) begin
                            input_channel_q <= '0;
                            if (kernel_column_q == LAST_KERNEL_INDEX) begin
                                kernel_column_q <= '0;
                                if (kernel_row_q == LAST_KERNEL_INDEX) begin
                                    kernel_row_q <= '0;
                                    state_q <= STATE_ADD_BIAS;
                                end else begin
                                    kernel_row_q <= kernel_row_q + 1'b1;
                                    activation_candidate_q <=
                                        activation_candidate_q
                                      + activation_row_jump_comb;
                                    weight_index_q <= weight_index_q + 1'b1;
                                    state_q <= STATE_ISSUE_MAC;
                                end
                            end else begin
                                kernel_column_q <= kernel_column_q + 1'b1;
                                activation_candidate_q <=
                                    activation_candidate_q + 1'b1;
                                weight_index_q <= weight_index_q + 1'b1;
                                state_q <= STATE_ISSUE_MAC;
                            end
                        end else begin
                            input_channel_q <= input_channel_q + 1'b1;
                            activation_candidate_q <=
                                activation_candidate_q + 1'b1;
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
                    output_write_addr_o <= output_address_comb;
                    output_data_o <= final_output_comb;
                    output_raw_acc_o <= biased_accumulator_q;
                    output_requantized_o <= requantized_comb;
                    accumulator_q <= '0;
                    biased_accumulator_q <= '0;
                    kernel_row_q <= '0;
                    kernel_column_q <= '0;
                    input_channel_q <= '0;
                    output_index_q <= output_index_q + 1'b1;

                    if (output_channel_q == output_channels_q - 1'b1) begin
                        output_channel_q <= '0;
                        weight_index_q <= '0;
                        if (output_column_q == output_width_q - 1'b1) begin
                            output_column_q <= '0;
                            if (output_row_q == output_height_q - 1'b1) begin
                                output_row_q <= '0;
                                busy_o <= 1'b0;
                                done_o <= 1'b1;
                                state_q <= STATE_IDLE;
                            end else begin
                                output_row_q <= output_row_q + 1'b1;
                                output_row_base_q <= output_row_base_q
                                                   + input_row_stride_q;
                                kernel_origin_q <= output_row_base_q
                                                 + input_row_stride_q
                                                 - padding_total_q;
                                activation_candidate_q <= output_row_base_q
                                                        + input_row_stride_q
                                                        - padding_total_q;
                                state_q <= STATE_ISSUE_MAC;
                            end
                        end else begin
                            output_column_q <= output_column_q + 1'b1;
                            kernel_origin_q <= kernel_origin_q
                                             + $signed({1'b0,
                                                 input_channels_q});
                            activation_candidate_q <= kernel_origin_q
                                                    + $signed({1'b0,
                                                        input_channels_q});
                            state_q <= STATE_ISSUE_MAC;
                        end
                    end else begin
                        output_channel_q <= output_channel_q + 1'b1;
                        weight_index_q <= weight_index_q + 1'b1;
                        activation_candidate_q <= kernel_origin_q;
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
