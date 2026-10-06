`timescale 1ns/1ps

// Combinational signed INT8 parameter store.
// Interface: one read enable/address input and one signed data output.
// Latency: zero cycles. Disabled and out-of-range reads return zero.
// Signedness: stored/read data are signed; address and enable are unsigned.
// The memory array is initialized by the testbench or an implementation flow.
module weight_rom #(
    parameter int DATA_W = 8,
    parameter int DEPTH = 1528,
    parameter int ADDR_W = 24
) (
    input  logic                         read_en_i,
    input  logic [ADDR_W-1:0]            read_addr_i,
    output logic signed [DATA_W-1:0]     read_data_o
);

    logic signed [DATA_W-1:0] memory [0:DEPTH-1];

    // Continuous read avoids excessive event scheduling in Icarus when a
    // variable-index memory read is expressed in always_comb.
    assign read_data_o =
        (read_en_i && (read_addr_i < DEPTH))
        ? memory[read_addr_i] : {DATA_W{1'b0}};

endmodule
