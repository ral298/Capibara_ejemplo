`timescale 1ns/1ps

// Sequential global average pool for the fixed 16x16 post-ReLU tensor.
// Interface: start/busy/done, combinational INT8 reads, registered INT8 writes.
// Latency: 256 reads and one write per channel.
// Signedness: input/output are signed INT8 and the running sum is INT32.
//
// State transition table:
// IDLE  : start_i ? ACCUMULATE : IDLE
// ACCUMULATE : final spatial sample ? WRITE : ACCUMULATE
// WRITE : final channel ? IDLE : ACCUMULATE
module global_avg_pool #(
    parameter int HEIGHT = 16,
    parameter int WIDTH = 16,
    parameter int CHANNELS = 16,
    parameter int DATA_W = 8,
    parameter int ACC_W = 32,
    parameter int ADDR_W = 24,
    parameter int COUNT_W = 16
) (
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic                         start_i,
    output logic                         busy_o,
    output logic                         done_o,
    output logic                         input_read_en_o,
    output logic [ADDR_W-1:0]            input_read_addr_o,
    input  logic signed [DATA_W-1:0]     input_read_data_i,
    output logic                         output_valid_o,
    output logic [ADDR_W-1:0]            output_write_addr_o,
    output logic signed [DATA_W-1:0]     output_data_o
);

    function automatic integer repeated_add(
        input integer value,
        input integer repetitions
    );
        integer repetition_index;
        begin
            repeated_add = 0;
            for (repetition_index = 0; repetition_index < repetitions;
                 repetition_index = repetition_index + 1) begin
                repeated_add = repeated_add + value;
            end
        end
    endfunction

    localparam int SPATIAL_SAMPLES = repeated_add(WIDTH, HEIGHT);
    localparam int AVERAGE_SHIFT = 8;

    typedef enum logic [1:0] {
        STATE_IDLE,
        STATE_ACCUMULATE,
        STATE_WRITE
    } state_t;

    state_t state_q;
    logic [COUNT_W-1:0] channel_q;
    logic [COUNT_W-1:0] sample_count_q;
    logic [ADDR_W-1:0] input_address_q;
    logic signed [ACC_W-1:0] accumulator_q;
    logic signed [ACC_W:0] sum_extended_comb;
    logic signed [ACC_W-1:0] sum_with_sample_comb;
    logic signed [ACC_W-1:0] average_comb;

    always_comb begin
        input_read_en_o = (state_q == STATE_ACCUMULATE);
        input_read_addr_o = input_address_q;
        sum_extended_comb =
            $signed({accumulator_q[ACC_W-1], accumulator_q})
          + $signed({{(ACC_W-DATA_W+1){input_read_data_i[DATA_W-1]}},
                     input_read_data_i});
        sum_with_sample_comb = sum_extended_comb[ACC_W-1:0];
        average_comb = $signed(sum_with_sample_comb) >>> AVERAGE_SHIFT;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_q <= STATE_IDLE;
            busy_o <= 1'b0;
            done_o <= 1'b0;
            output_valid_o <= 1'b0;
            output_write_addr_o <= '0;
            output_data_o <= '0;
            channel_q <= '0;
            sample_count_q <= '0;
            input_address_q <= '0;
            accumulator_q <= '0;
        end else begin
            done_o <= 1'b0;
            output_valid_o <= 1'b0;
            case (state_q)
                STATE_IDLE: begin
                    busy_o <= 1'b0;
                    if (start_i) begin
                        busy_o <= 1'b1;
                        channel_q <= '0;
                        sample_count_q <= '0;
                        input_address_q <= '0;
                        accumulator_q <= '0;
                        state_q <= STATE_ACCUMULATE;
                    end
                end

                STATE_ACCUMULATE: begin
                    accumulator_q <= sum_with_sample_comb;
                    if (sample_count_q == SPATIAL_SAMPLES - 1) begin
                        sample_count_q <= '0;
                        state_q <= STATE_WRITE;
                    end else begin
                        sample_count_q <= sample_count_q + 1'b1;
                        input_address_q <= input_address_q + CHANNELS;
                    end
                end

                STATE_WRITE: begin
                    output_valid_o <= 1'b1;
                    output_write_addr_o <= channel_q;
                    output_data_o <= average_comb[DATA_W-1:0];
                    accumulator_q <= '0;
                    if (channel_q == CHANNELS - 1) begin
                        channel_q <= '0;
                        busy_o <= 1'b0;
                        done_o <= 1'b1;
                        state_q <= STATE_IDLE;
                    end else begin
                        channel_q <= channel_q + 1'b1;
                        input_address_q <= channel_q + 1'b1;
                        state_q <= STATE_ACCUMULATE;
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
