`timescale 1ns/1ps

// Single-write-port activation RAM with an asynchronous simulation-friendly
// read port. Interface: one synchronous write port and one combinational read.
// Read latency: zero cycles. Write latency: data is stored on the rising edge.
// Signedness: read and write data are signed; addresses/control are unsigned.
// A disabled or out-of-range read returns zero, preventing X propagation.
module sync_ram #(
    parameter int DATA_W = 8,
    parameter int DEPTH = 16,
    parameter int ADDR_W = 24
) (
    input  logic                         clk,
    input  logic                         write_en_i,
    input  logic [ADDR_W-1:0]            write_addr_i,
    input  logic signed [DATA_W-1:0]     write_data_i,
    input  logic                         read_en_i,
    input  logic [ADDR_W-1:0]            read_addr_i,
    output logic signed [DATA_W-1:0]     read_data_o
);

    logic signed [DATA_W-1:0] memory [0:DEPTH-1];

    always_ff @(posedge clk) begin
        if (write_en_i && (write_addr_i < DEPTH)) begin
            memory[write_addr_i] <= write_data_i;
        end
    end

    // Continuous read avoids excessive event scheduling in Icarus when a
    // variable-index memory read is expressed in always_comb.
    assign read_data_o =
        (read_en_i && (read_addr_i < DEPTH))
        ? memory[read_addr_i] : {DATA_W{1'b0}};

endmodule
