# Entradas síncronas
set_input_delay 1.0 -clock reloj [get_ports enable]
set_input_delay 1.0 -clock reloj [get_ports suma_resta]

# Salida
set_output_delay 1.0 -clock reloj [get_ports {resultado[*]}]

# Reset asíncrono activo en bajo
set_false_path -from [get_ports reset]