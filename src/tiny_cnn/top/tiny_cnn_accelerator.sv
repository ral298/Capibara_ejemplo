`timescale 1ns/1ps

// End-to-end fixed INT8 CNN accelerator.
// Interface: start/busy/done transaction, four-bit predicted class, and an
// optional registered logit debug stream.
// Latency: sequential layer execution with one shared convolution MAC lane.
// Signedness: activation/weight stores are INT8; biases/logits are INT32.
//
// HWC activation maps use address ((row times width) plus column) times
// channels plus channel. Convolution weights use OHWI order; FC weights use
// output-major OI order. Runtime products are avoided by supplying precomputed
// strides to the shared convolution engine.
module tiny_cnn_accelerator #(
    parameter bit DEBUG_TRACE = 1'b0,
    parameter int ADDR_W = 24,
    parameter logic [4:0] CONV1_REQUANT_SHIFT = 5'd9,
    parameter logic [4:0] CONV2_REQUANT_SHIFT = 5'd9
) (
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic                         start,
    output logic                         busy,
    output logic                         done,
    output logic [3:0]                   predicted_class,
    output logic                         debug_logit_valid_o,
    output logic [3:0]                   debug_logit_index_o,
    output logic signed [31:0]           debug_logit_o
);

    localparam int ACT_W = 8;
    localparam int WGT_W = 8;
    localparam int ACC_W = 32;
    localparam int SHIFT_W = 5;
    localparam int COUNT_W = 16;

    localparam int INPUT_DEPTH = 3072;
    localparam int CONV1_DEPTH = 8192;
    localparam int POOL_DEPTH = 2048;
    localparam int CONV2_DEPTH = 4096;
    localparam int GAP_DEPTH = 16;
    localparam int WEIGHT_DEPTH = 1528;
    localparam int BIAS_DEPTH = 34;

    localparam int CONV1_WEIGHT_BASE = 0;
    localparam int CONV2_WEIGHT_BASE = 216;
    localparam int FC_WEIGHT_BASE = 1368;
    localparam int CONV1_BIAS_BASE = 0;
    localparam int CONV2_BIAS_BASE = 8;
    localparam int FC_BIAS_BASE = 24;

    logic conv1_start;
    logic pool_start;
    logic conv2_start;
    logic gap_start;
    logic fc_start;
    logic argmax_capture;

    logic conv_busy;
    logic conv_done;
    logic pool_busy;
    logic pool_done;
    logic gap_busy;
    logic gap_done;
    logic fc_busy;
    logic fc_done;
    logic conv_layer_q;

    logic [COUNT_W-1:0] conv_input_height;
    logic [COUNT_W-1:0] conv_input_width;
    logic [COUNT_W-1:0] conv_input_channels;
    logic [COUNT_W-1:0] conv_output_height;
    logic [COUNT_W-1:0] conv_output_width;
    logic [COUNT_W-1:0] conv_output_channels;
    logic [COUNT_W-1:0] conv_padding;
    logic signed [ADDR_W:0] conv_input_row_stride;
    logic signed [ADDR_W:0] conv_kernel_row_span;
    logic signed [ADDR_W:0] conv_padding_total;
    logic [SHIFT_W-1:0] conv_requant_shift;

    logic conv_activation_read_en;
    logic [ADDR_W-1:0] conv_activation_read_addr;
    logic signed [ACT_W-1:0] conv_activation_read_data;
    logic conv_weight_read_en;
    logic [ADDR_W-1:0] conv_weight_local_addr;
    logic conv_bias_read_en;
    logic [ADDR_W-1:0] conv_bias_local_addr;
    logic conv_output_valid;
    logic [ADDR_W-1:0] conv_output_write_addr;
    logic signed [ACC_W-1:0] conv_output_data;
    logic signed [ACC_W-1:0] conv_output_raw_acc;
    logic signed [ACT_W-1:0] conv_output_requantized;

    logic input_read_en;
    logic [ADDR_W-1:0] input_read_addr;
    logic signed [ACT_W-1:0] input_read_data;
    logic conv1_read_en;
    logic [ADDR_W-1:0] conv1_read_addr;
    logic signed [ACT_W-1:0] conv1_read_data;
    logic pool_read_en;
    logic [ADDR_W-1:0] pool_read_addr;
    logic signed [ACT_W-1:0] pool_read_data;
    logic conv2_read_en;
    logic [ADDR_W-1:0] conv2_read_addr;
    logic signed [ACT_W-1:0] conv2_read_data;
    logic gap_read_en;
    logic [ADDR_W-1:0] gap_read_addr;
    logic signed [ACT_W-1:0] gap_read_data;

    logic pool_output_valid;
    logic [ADDR_W-1:0] pool_output_write_addr;
    logic signed [ACT_W-1:0] pool_output_data;
    logic gap_output_valid;
    logic [ADDR_W-1:0] gap_output_write_addr;
    logic signed [ACT_W-1:0] gap_output_data;
    logic fc_output_valid;
    logic [ADDR_W-1:0] fc_output_write_addr;
    logic signed [ACC_W-1:0] fc_output_data;

    logic fc_activation_read_en;
    logic [ADDR_W-1:0] fc_activation_read_addr;
    logic fc_weight_read_en;
    logic [ADDR_W-1:0] fc_weight_local_addr;
    logic fc_bias_read_en;
    logic [ADDR_W-1:0] fc_bias_local_addr;

    logic weight_read_en;
    logic [ADDR_W-1:0] weight_read_addr;
    logic signed [WGT_W-1:0] weight_read_data;
    logic bias_read_en;
    logic [ADDR_W-1:0] bias_read_addr;
    logic signed [ACC_W-1:0] bias_read_data;

    logic signed [ACC_W-1:0] logits_q [0:9];
    logic [3:0] argmax_index;
    logic signed [ACC_W-1:0] argmax_maximum;
    integer logit_reset_index;

    cnn_controller u_controller (
        .clk              (clk),
        .rst_n            (rst_n),
        .start_i          (start),
        .conv_done_i      (conv_done),
        .pool_done_i      (pool_done),
        .gap_done_i       (gap_done),
        .fc_done_i        (fc_done),
        .conv1_start_o    (conv1_start),
        .pool_start_o     (pool_start),
        .conv2_start_o    (conv2_start),
        .gap_start_o      (gap_start),
        .fc_start_o       (fc_start),
        .argmax_capture_o (argmax_capture),
        .busy_o           (busy),
        .done_o           (done)
    );

    always_comb begin
        conv_input_height = 32;
        conv_input_width = 32;
        conv_input_channels = 3;
        conv_output_height = 32;
        conv_output_width = 32;
        conv_output_channels = 8;
        conv_padding = 1;
        conv_input_row_stride = 96;
        conv_kernel_row_span = 9;
        conv_padding_total = 99;
        conv_requant_shift = CONV1_REQUANT_SHIFT;
        if (conv2_start || conv_layer_q) begin
            conv_input_height = 16;
            conv_input_width = 16;
            conv_input_channels = 8;
            conv_output_height = 16;
            conv_output_width = 16;
            conv_output_channels = 16;
            conv_padding = 1;
            conv_input_row_stride = 128;
            conv_kernel_row_span = 24;
            conv_padding_total = 136;
            conv_requant_shift = CONV2_REQUANT_SHIFT;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            conv_layer_q <= 1'b0;
        end else begin
            if (conv1_start) begin
                conv_layer_q <= 1'b0;
            end else if (conv2_start) begin
                conv_layer_q <= 1'b1;
            end
        end
    end

    convolution_engine #(
        .ACT_W(ACT_W),
        .WGT_W(WGT_W),
        .ACC_W(ACC_W),
        .SHIFT_W(SHIFT_W),
        .COUNT_W(COUNT_W),
        .ADDR_W(ADDR_W)
    ) u_convolution_engine (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .start_i                (conv1_start || conv2_start),
        .requant_enable_i       (1'b1),
        .relu_enable_i          (1'b1),
        .shift_i                (conv_requant_shift),
        .input_height_i         (conv_input_height),
        .input_width_i          (conv_input_width),
        .input_channels_i       (conv_input_channels),
        .output_height_i        (conv_output_height),
        .output_width_i         (conv_output_width),
        .output_channels_i      (conv_output_channels),
        .padding_i              (conv_padding),
        .input_row_stride_i     (conv_input_row_stride),
        .kernel_row_span_i      (conv_kernel_row_span),
        .padding_total_i        (conv_padding_total),
        .busy_o                 (conv_busy),
        .done_o                 (conv_done),
        .activation_read_en_o   (conv_activation_read_en),
        .activation_read_addr_o (conv_activation_read_addr),
        .activation_read_data_i (conv_activation_read_data),
        .weight_read_en_o       (conv_weight_read_en),
        .weight_read_addr_o     (conv_weight_local_addr),
        .weight_read_data_i     (weight_read_data),
        .bias_read_en_o         (conv_bias_read_en),
        .bias_read_addr_o       (conv_bias_local_addr),
        .bias_read_data_i       (bias_read_data),
        .output_valid_o         (conv_output_valid),
        .output_write_addr_o    (conv_output_write_addr),
        .output_data_o          (conv_output_data),
        .output_raw_acc_o       (conv_output_raw_acc),
        .output_requantized_o   (conv_output_requantized)
    );

    assign input_read_en = conv_activation_read_en && !conv_layer_q;
    assign input_read_addr = conv_activation_read_addr;
    assign pool_read_en = conv_activation_read_en && conv_layer_q;
    assign pool_read_addr = conv_activation_read_addr;
    assign conv_activation_read_data =
        conv_layer_q ? pool_read_data : input_read_data;

    maxpool_layer u_maxpool_layer (
        .clk                 (clk),
        .rst_n               (rst_n),
        .start_i             (pool_start),
        .busy_o              (pool_busy),
        .done_o              (pool_done),
        .input_read_en_o     (conv1_read_en),
        .input_read_addr_o   (conv1_read_addr),
        .input_read_data_i   (conv1_read_data),
        .output_valid_o      (pool_output_valid),
        .output_write_addr_o (pool_output_write_addr),
        .output_data_o       (pool_output_data)
    );

    global_avg_pool u_global_avg_pool (
        .clk                 (clk),
        .rst_n               (rst_n),
        .start_i             (gap_start),
        .busy_o              (gap_busy),
        .done_o              (gap_done),
        .input_read_en_o     (conv2_read_en),
        .input_read_addr_o   (conv2_read_addr),
        .input_read_data_i   (conv2_read_data),
        .output_valid_o      (gap_output_valid),
        .output_write_addr_o (gap_output_write_addr),
        .output_data_o       (gap_output_data)
    );

    fully_connected u_fully_connected (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .start_i                (fc_start),
        .busy_o                 (fc_busy),
        .done_o                 (fc_done),
        .activation_read_en_o   (fc_activation_read_en),
        .activation_read_addr_o (fc_activation_read_addr),
        .activation_read_data_i (gap_read_data),
        .weight_read_en_o       (fc_weight_read_en),
        .weight_read_addr_o     (fc_weight_local_addr),
        .weight_read_data_i     (weight_read_data),
        .bias_read_en_o         (fc_bias_read_en),
        .bias_read_addr_o       (fc_bias_local_addr),
        .bias_read_data_i       (bias_read_data),
        .output_valid_o         (fc_output_valid),
        .output_write_addr_o    (fc_output_write_addr),
        .output_data_o          (fc_output_data)
    );

    assign gap_read_en = fc_activation_read_en;
    assign gap_read_addr = fc_activation_read_addr;

    always_comb begin
        weight_read_en = 1'b0;
        weight_read_addr = '0;
        bias_read_en = 1'b0;
        bias_read_addr = '0;
        if (conv_weight_read_en) begin
            weight_read_en = 1'b1;
            if (conv_layer_q) begin
                weight_read_addr = CONV2_WEIGHT_BASE + conv_weight_local_addr;
            end else begin
                weight_read_addr = CONV1_WEIGHT_BASE + conv_weight_local_addr;
            end
        end else if (fc_weight_read_en) begin
            weight_read_en = 1'b1;
            weight_read_addr = FC_WEIGHT_BASE + fc_weight_local_addr;
        end
        if (conv_bias_read_en) begin
            bias_read_en = 1'b1;
            if (conv_layer_q) begin
                bias_read_addr = CONV2_BIAS_BASE + conv_bias_local_addr;
            end else begin
                bias_read_addr = CONV1_BIAS_BASE + conv_bias_local_addr;
            end
        end else if (fc_bias_read_en) begin
            bias_read_en = 1'b1;
            bias_read_addr = FC_BIAS_BASE + fc_bias_local_addr;
        end
    end

    sync_ram #(
        .DATA_W(ACT_W),
        .DEPTH(INPUT_DEPTH),
        .ADDR_W(ADDR_W)
    ) u_input_memory (
        .clk          (clk),
        .write_en_i   (1'b0),
        .write_addr_i ({ADDR_W{1'b0}}),
        .write_data_i ({ACT_W{1'b0}}),
        .read_en_i    (input_read_en),
        .read_addr_i  (input_read_addr),
        .read_data_o  (input_read_data)
    );

    sync_ram #(
        .DATA_W(ACT_W),
        .DEPTH(CONV1_DEPTH),
        .ADDR_W(ADDR_W)
    ) u_conv1_memory (
        .clk          (clk),
        .write_en_i   (conv_output_valid && !conv_layer_q),
        .write_addr_i (conv_output_write_addr),
        .write_data_i (conv_output_data[ACT_W-1:0]),
        .read_en_i    (conv1_read_en),
        .read_addr_i  (conv1_read_addr),
        .read_data_o  (conv1_read_data)
    );

    sync_ram #(
        .DATA_W(ACT_W),
        .DEPTH(POOL_DEPTH),
        .ADDR_W(ADDR_W)
    ) u_pool_memory (
        .clk          (clk),
        .write_en_i   (pool_output_valid),
        .write_addr_i (pool_output_write_addr),
        .write_data_i (pool_output_data),
        .read_en_i    (pool_read_en),
        .read_addr_i  (pool_read_addr),
        .read_data_o  (pool_read_data)
    );

    sync_ram #(
        .DATA_W(ACT_W),
        .DEPTH(CONV2_DEPTH),
        .ADDR_W(ADDR_W)
    ) u_conv2_memory (
        .clk          (clk),
        .write_en_i   (conv_output_valid && conv_layer_q),
        .write_addr_i (conv_output_write_addr),
        .write_data_i (conv_output_data[ACT_W-1:0]),
        .read_en_i    (conv2_read_en),
        .read_addr_i  (conv2_read_addr),
        .read_data_o  (conv2_read_data)
    );

    sync_ram #(
        .DATA_W(ACT_W),
        .DEPTH(GAP_DEPTH),
        .ADDR_W(ADDR_W)
    ) u_gap_memory (
        .clk          (clk),
        .write_en_i   (gap_output_valid),
        .write_addr_i (gap_output_write_addr),
        .write_data_i (gap_output_data),
        .read_en_i    (gap_read_en),
        .read_addr_i  (gap_read_addr),
        .read_data_o  (gap_read_data)
    );

    weight_rom #(
        .DATA_W(WGT_W),
        .DEPTH(WEIGHT_DEPTH),
        .ADDR_W(ADDR_W)
    ) u_weight_rom (
        .read_en_i   (weight_read_en),
        .read_addr_i (weight_read_addr),
        .read_data_o (weight_read_data)
    );

    bias_rom #(
        .DATA_W(ACC_W),
        .DEPTH(BIAS_DEPTH),
        .ADDR_W(ADDR_W)
    ) u_bias_rom (
        .read_en_i   (bias_read_en),
        .read_addr_i (bias_read_addr),
        .read_data_o (bias_read_data)
    );

    argmax #(
        .NUM_VALUES(10),
        .DATA_W(ACC_W),
        .INDEX_W(4)
    ) u_argmax (
        .values_i  (logits_q),
        .index_o   (argmax_index),
        .maximum_o (argmax_maximum)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            predicted_class <= '0;
            debug_logit_valid_o <= 1'b0;
            debug_logit_index_o <= '0;
            debug_logit_o <= '0;
            for (logit_reset_index = 0; logit_reset_index < 10;
                 logit_reset_index = logit_reset_index + 1) begin
                logits_q[logit_reset_index] <= '0;
            end
        end else begin
            debug_logit_valid_o <= fc_output_valid;
            if (fc_output_valid) begin
                logits_q[fc_output_write_addr[3:0]] <= fc_output_data;
                debug_logit_index_o <= fc_output_write_addr[3:0];
                debug_logit_o <= fc_output_data;
            end
            if (argmax_capture) begin
                predicted_class <= argmax_index;
            end
        end
    end

`ifndef SYNTHESIS
    integer conv1_write_count_q;
    integer pool_write_count_q;
    integer conv2_write_count_q;
    integer gap_write_count_q;
    integer fc_write_count_q;
    integer trace_logit_index;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            conv1_write_count_q <= 0;
            pool_write_count_q <= 0;
            conv2_write_count_q <= 0;
            gap_write_count_q <= 0;
            fc_write_count_q <= 0;
        end else if (DEBUG_TRACE) begin
            if (conv1_start) begin
                conv1_write_count_q <= 0;
                $display("TRACE layer_start conv1");
            end
            if (pool_start) begin
                pool_write_count_q <= 0;
                $display("TRACE layer_start maxpool");
            end
            if (conv2_start) begin
                conv2_write_count_q <= 0;
                $display("TRACE layer_start conv2");
            end
            if (gap_start) begin
                gap_write_count_q <= 0;
                $display("TRACE layer_start gap");
            end
            if (fc_start) begin
                fc_write_count_q <= 0;
                $display("TRACE layer_start fc");
            end
            if (conv_output_valid && !conv_layer_q) begin
                conv1_write_count_q <= conv1_write_count_q + 1;
            end
            if (pool_output_valid) begin
                pool_write_count_q <= pool_write_count_q + 1;
            end
            if (conv_output_valid && conv_layer_q) begin
                conv2_write_count_q <= conv2_write_count_q + 1;
            end
            if (gap_output_valid) begin
                gap_write_count_q <= gap_write_count_q + 1;
            end
            if (fc_output_valid) begin
                fc_write_count_q <= fc_write_count_q + 1;
            end
            if (conv_done && !conv_layer_q) begin
                $display("TRACE layer_finish conv1 writes=%0d",
                         conv1_write_count_q + 1);
            end
            if (pool_done) begin
                $display("TRACE layer_finish maxpool writes=%0d",
                         pool_write_count_q + 1);
            end
            if (conv_done && conv_layer_q) begin
                $display("TRACE layer_finish conv2 writes=%0d",
                         conv2_write_count_q + 1);
            end
            if (gap_done) begin
                $display("TRACE layer_finish gap writes=%0d",
                         gap_write_count_q + 1);
            end
            if (fc_done) begin
                $display("TRACE layer_finish fc writes=%0d",
                         fc_write_count_q + 1);
            end
            if (argmax_capture) begin
                for (trace_logit_index = 0; trace_logit_index < 10;
                     trace_logit_index = trace_logit_index + 1) begin
                    $display("TRACE final_logit index=%0d value=%0d",
                             trace_logit_index,
                             $signed(logits_q[trace_logit_index]));
                end
            end
        end
    end
`endif

endmodule
