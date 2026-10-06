// SPDX-FileCopyrightText: © 2025 XXX Authors
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module chip_core #(
    parameter NUM_INPUT_PADS,
    parameter NUM_BIDIR_PADS,
    parameter NUM_ANALOG_PADS
    )(
    `ifdef USE_POWER_PINS
    inout  wire VDD,
    inout  wire VSS,
    `endif
    input  wire clk,       // clock
    input  wire rst_n,     // reset (active low)
    
    input  wire [NUM_INPUT_PADS-1:0] input_in,   // Input value
    output wire [NUM_INPUT_PADS-1:0] input_pu,   // Pull-up
    output wire [NUM_INPUT_PADS-1:0] input_pd,   // Pull-down

    input  wire [NUM_BIDIR_PADS-1:0] bidir_in,   // Input value
    output wire [NUM_BIDIR_PADS-1:0] bidir_out,  // Output value
    output wire [NUM_BIDIR_PADS-1:0] bidir_oe,   // Output enable
    output wire [NUM_BIDIR_PADS-1:0] bidir_cs,   // Input type (0=CMOS Buffer, 1=Schmitt Trigger)
    output wire [NUM_BIDIR_PADS-1:0] bidir_sl,   // Slew rate (0=fast, 1=slow)
    output wire [NUM_BIDIR_PADS-1:0] bidir_ie,   // Input enable
    output wire [NUM_BIDIR_PADS-1:0] bidir_pu,   // Pull-up
    output wire [NUM_BIDIR_PADS-1:0] bidir_pd,   // Pull-down

    inout  wire [NUM_ANALOG_PADS-1:0] analog
);
    // See here for usage: https://gf180mcu-pdk.readthedocs.io/en/latest/IPs/IO/gf180mcu_fd_io/digital.html
    
    // ============================================================
    // Pines de entrada dedicados:
    // NO se utilizan en este proyecto.
    // ============================================================

    assign input_pu = '0;
    assign input_pd = '0;



    wire [3:0] resultado_contador;
   
    // ============================================================
    // Instancia del contador
    // ============================================================
    //enable tiene que ser bidir_in[0]
    //suma_resta tiene que ser bidir_in[1]
    //resultado_contador tiene que ser la variable "resultado" de la instancia

    contador contador_u (
        .reloj      (clk),
        .reset      (rst_n),
        .enable     (bidir_in[0]),
        .suma_resta (bidir_in[1]),
        .resultado  (resultado_contador)
    );

    /*(* keep *)
    D14_topcell D14_topcell_u(
        .Vin        (analog[0]),
        .Vin_neg    (analog[1]),
        .vw11       (analog[2]),
        .vw42       (analog[3]),
        .vpre1      (analog[4]),
        .vpre2      (analog[5]),
        .vpost1     (analog[6]),
        .vpost2     (analog[7])
    );*/
    
    
    //Configurar bidir_out, que resultado_contador tiene que estar en los bits 5:2
    // usar assign

    assign bidir_out = {
        {(NUM_BIDIR_PADS-6){1'b0}},
        resultado_contador,
        2'b00
    };
    //Configurar bidir_oe, que resultado_contador tiene que estar en los bits 5:2 como salidas y las entradas para los bits 1:0
    // usar assign
    assign bidir_oe = {
        {(NUM_BIDIR_PADS-6){1'b0}},
        4'b1111,
        2'b00
    };
    //Configurar bidir_ie, que resultado_contador tiene que estar en los bits 5:2 como salidas y las entradas para los bits 1:0
    // usar assign
    assign bidir_ie = {
        {(NUM_BIDIR_PADS-6){1'b0}},
        ~bidir_oe[5:0]
    };
    //usar bidir_cs, bidir_sl, bidir_pu, bidir_pd todo en 0, se explicara| el porque
    assign bidir_cs = '0;
    assign bidir_sl = '0;
    assign bidir_pu = '0;
    assign bidir_pd = '0;






    wire _unused;
    assign _unused = &{1'b0, input_in, bidir_in[NUM_BIDIR_PADS-1:2]};

endmodule

`default_nettype wire


