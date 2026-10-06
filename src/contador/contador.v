module contador (
    input  wire       reloj,
    input  wire       reset,
    input  wire       enable,
    input  wire       suma_resta,
    output reg  [3:0] resultado
);

    wire [3:0] suma;

    // suma_resta = 1 -> suma 1
    // suma_resta = 0 -> resta 1
    assign suma = resultado + (suma_resta ? 4'b0001 : 4'b1111);

    always @(posedge reloj, negedge reset) begin
        if (!reset)
            resultado <= 4'b0000;
        else if (enable)
            resultado <= suma;
    end

endmodule