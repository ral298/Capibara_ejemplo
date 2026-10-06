`timescale 1ns/1ps

// Sequential HWC 2x2, stride-two max-pooling layer.
// Interface: start/busy/done, combinational INT8 reads, registered INT8 writes.
// Latency: four read cycles and one write cycle per output.
// Signedness: all samples and outputs are signed INT8.
//
// State transition table:
// IDLE  : start_i ? READ : IDLE
// READ  : fourth sample ? WRITE : READ
// WRITE : final output ? IDLE : READ
module maxpool_layer #(
    parameter int IN_H = 32,
    parameter int IN_W = 32,
    parameter int CHANNELS = 8,
    parameter int DATA_W = 8,
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

    localparam int OUT_H = IN_H / 2;
    localparam int OUT_W = IN_W / 2;
    localparam int INPUT_ROW_STRIDE = repeated_add(CHANNELS, IN_W);
    localparam int COLUMN_STEP = CHANNELS + CHANNELS;
    localparam int ROW_STEP = INPUT_ROW_STRIDE + INPUT_ROW_STRIDE;

    typedef enum logic [1:0] {
        STATE_IDLE,
        STATE_READ,
        STATE_WRITE
    } state_t;

    state_t state_q;
    logic [COUNT_W-1:0] output_row_q;
    logic [COUNT_W-1:0] output_column_q;
    logic [COUNT_W-1:0] channel_q;
    logic [1:0] sample_index_q;
    logic [ADDR_W-1:0] spatial_origin_q;
    logic [ADDR_W-1:0] row_base_q;
    logic [ADDR_W-1:0] output_index_q;
    logic signed [DATA_W-1:0] sample_0_q;
    logic signed [DATA_W-1:0] sample_1_q;
    logic signed [DATA_W-1:0] sample_2_q;
    logic signed [DATA_W-1:0] sample_3_q;
    logic signed [DATA_W-1:0] maximum_comb;

    maxpool2x2 #(
        .DATA_W(DATA_W)
    ) u_maxpool2x2 (
        .sample_0_i (sample_0_q),
        .sample_1_i (sample_1_q),
        .sample_2_i (sample_2_q),
        .sample_3_i (sample_3_q),
        .maximum_o  (maximum_comb)
    );

    always_comb begin
        input_read_en_o = (state_q == STATE_READ);
        input_read_addr_o = spatial_origin_q + channel_q;
        case (sample_index_q)
            2'd1: input_read_addr_o =
                spatial_origin_q + channel_q + CHANNELS;
            2'd2: input_read_addr_o =
                spatial_origin_q + channel_q + INPUT_ROW_STRIDE;
            2'd3: input_read_addr_o =
                spatial_origin_q + channel_q + INPUT_ROW_STRIDE + CHANNELS;
            default: input_read_addr_o = spatial_origin_q + channel_q;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_q <= STATE_IDLE;
            busy_o <= 1'b0;
            done_o <= 1'b0;
            output_valid_o <= 1'b0;
            output_write_addr_o <= '0;
            output_data_o <= '0;
            output_row_q <= '0;
            output_column_q <= '0;
            channel_q <= '0;
            sample_index_q <= '0;
            spatial_origin_q <= '0;
            row_base_q <= '0;
            output_index_q <= '0;
            sample_0_q <= '0;
            sample_1_q <= '0;
            sample_2_q <= '0;
            sample_3_q <= '0;
        end else begin
            done_o <= 1'b0;
            output_valid_o <= 1'b0;
            case (state_q)
                STATE_IDLE: begin
                    busy_o <= 1'b0;
                    if (start_i) begin
                        busy_o <= 1'b1;
                        output_row_q <= '0;
                        output_column_q <= '0;
                        channel_q <= '0;
                        sample_index_q <= '0;
                        spatial_origin_q <= '0;
                        row_base_q <= '0;
                        output_index_q <= '0;
                        sample_0_q <= '0;
                        sample_1_q <= '0;
                        sample_2_q <= '0;
                        sample_3_q <= '0;
                        state_q <= STATE_READ;
                    end
                end

                STATE_READ: begin
                    case (sample_index_q)
                        2'd0: sample_0_q <= input_read_data_i;
                        2'd1: sample_1_q <= input_read_data_i;
                        2'd2: sample_2_q <= input_read_data_i;
                        default: sample_3_q <= input_read_data_i;
                    endcase
                    if (sample_index_q == 2'd3) begin
                        sample_index_q <= '0;
                        state_q <= STATE_WRITE;
                    end else begin
                        sample_index_q <= sample_index_q + 1'b1;
                    end
                end

                STATE_WRITE: begin
                    output_valid_o <= 1'b1;
                    output_write_addr_o <= output_index_q;
                    output_data_o <= maximum_comb;
                    output_index_q <= output_index_q + 1'b1;
                    if (channel_q == CHANNELS - 1) begin
                        channel_q <= '0;
                        if (output_column_q == OUT_W - 1) begin
                            output_column_q <= '0;
                            if (output_row_q == OUT_H - 1) begin
                                output_row_q <= '0;
                                busy_o <= 1'b0;
                                done_o <= 1'b1;
                                state_q <= STATE_IDLE;
                            end else begin
                                output_row_q <= output_row_q + 1'b1;
                                row_base_q <= row_base_q + ROW_STEP;
                                spatial_origin_q <= row_base_q + ROW_STEP;
                                state_q <= STATE_READ;
                            end
                        end else begin
                            output_column_q <= output_column_q + 1'b1;
                            spatial_origin_q <= spatial_origin_q + COLUMN_STEP;
                            state_q <= STATE_READ;
                        end
                    end else begin
                        channel_q <= channel_q + 1'b1;
                        state_q <= STATE_READ;
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
