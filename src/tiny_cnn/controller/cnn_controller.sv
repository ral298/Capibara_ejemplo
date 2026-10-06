`timescale 1ns/1ps

// Fixed-CNN sequencing controller.
// Interface: one external transaction and per-layer start/done handshakes.
// Latency: layer-dependent. Every layer start is a one-cycle pulse.
// Signedness: this control-only block contains no signed datapath signals.
//
// State transition table:
// IDLE         : start_i ? START_CONV1 : IDLE
// START_CONV1  : WAIT_CONV1
// WAIT_CONV1   : conv_done_i ? START_POOL : WAIT_CONV1
// START_POOL   : WAIT_POOL
// WAIT_POOL    : pool_done_i ? START_CONV2 : WAIT_POOL
// START_CONV2  : WAIT_CONV2
// WAIT_CONV2   : conv_done_i ? START_GAP : WAIT_CONV2
// START_GAP    : WAIT_GAP
// WAIT_GAP     : gap_done_i ? START_FC : WAIT_GAP
// START_FC     : WAIT_FC
// WAIT_FC      : fc_done_i ? CAPTURE_ARGMAX : WAIT_FC
// CAPTURE_ARGMAX : DONE
// DONE         : IDLE
module cnn_controller (
    input  logic clk,
    input  logic rst_n,
    input  logic start_i,
    input  logic conv_done_i,
    input  logic pool_done_i,
    input  logic gap_done_i,
    input  logic fc_done_i,
    output logic conv1_start_o,
    output logic pool_start_o,
    output logic conv2_start_o,
    output logic gap_start_o,
    output logic fc_start_o,
    output logic argmax_capture_o,
    output logic busy_o,
    output logic done_o
);

    typedef enum logic [3:0] {
        STATE_IDLE,
        STATE_START_CONV1,
        STATE_WAIT_CONV1,
        STATE_START_POOL,
        STATE_WAIT_POOL,
        STATE_START_CONV2,
        STATE_WAIT_CONV2,
        STATE_START_GAP,
        STATE_WAIT_GAP,
        STATE_START_FC,
        STATE_WAIT_FC,
        STATE_CAPTURE_ARGMAX,
        STATE_DONE
    } state_t;

    state_t state_q;
    state_t state_d;

    always_comb begin
        state_d = state_q;
        conv1_start_o = 1'b0;
        pool_start_o = 1'b0;
        conv2_start_o = 1'b0;
        gap_start_o = 1'b0;
        fc_start_o = 1'b0;
        argmax_capture_o = 1'b0;
        busy_o = 1'b1;
        done_o = 1'b0;

        case (state_q)
            STATE_IDLE: begin
                busy_o = 1'b0;
                if (start_i) begin
                    state_d = STATE_START_CONV1;
                end
            end
            STATE_START_CONV1: begin
                conv1_start_o = 1'b1;
                state_d = STATE_WAIT_CONV1;
            end
            STATE_WAIT_CONV1: begin
                if (conv_done_i) begin
                    state_d = STATE_START_POOL;
                end
            end
            STATE_START_POOL: begin
                pool_start_o = 1'b1;
                state_d = STATE_WAIT_POOL;
            end
            STATE_WAIT_POOL: begin
                if (pool_done_i) begin
                    state_d = STATE_START_CONV2;
                end
            end
            STATE_START_CONV2: begin
                conv2_start_o = 1'b1;
                state_d = STATE_WAIT_CONV2;
            end
            STATE_WAIT_CONV2: begin
                if (conv_done_i) begin
                    state_d = STATE_START_GAP;
                end
            end
            STATE_START_GAP: begin
                gap_start_o = 1'b1;
                state_d = STATE_WAIT_GAP;
            end
            STATE_WAIT_GAP: begin
                if (gap_done_i) begin
                    state_d = STATE_START_FC;
                end
            end
            STATE_START_FC: begin
                fc_start_o = 1'b1;
                state_d = STATE_WAIT_FC;
            end
            STATE_WAIT_FC: begin
                if (fc_done_i) begin
                    state_d = STATE_CAPTURE_ARGMAX;
                end
            end
            STATE_CAPTURE_ARGMAX: begin
                argmax_capture_o = 1'b1;
                state_d = STATE_DONE;
            end
            STATE_DONE: begin
                busy_o = 1'b0;
                done_o = 1'b1;
                state_d = STATE_IDLE;
            end
            default: begin
                state_d = STATE_IDLE;
                busy_o = 1'b0;
            end
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_q <= STATE_IDLE;
        end else begin
            state_q <= state_d;
        end
    end

endmodule
