
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
        .enable 		(enable),
        .suma_resta 	(suma_resta),
        .resultado	(suma_out)
    );

endmodule
