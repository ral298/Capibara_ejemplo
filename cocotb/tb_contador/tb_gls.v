`timescale 1ns / 1ps

module tb ();

    initial begin
        $dumpfile("dump_gls.vcd");
        $dumpvars(0, tb); // Al apuntar a 'tb', grabará este módulo y todo lo que instancie adentro
        #1;
    end

    reg clk;
    reg rst;
    reg enable;
    reg suma_resta;

    wire [3:0] suma_out;

    contador user_project (
        .reloj         (clk),
        .reset          (rst),
        .enable         (enable),
        .suma_resta     (suma_resta),
        .resultado      (suma_out)
    );

`ifdef TIMING
    initial begin
        $display("============================================");
        $display(" Simulacion Gate-Level con anotacion SDF");
        $display(" SDF: %s", `SDF_FILE);
        $display(" DUT: tb.user_project");
        $display("============================================");

        $sdf_annotate(`SDF_FILE, user_project);
    end
`endif

endmodule
