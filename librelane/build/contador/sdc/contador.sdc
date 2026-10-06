###############################################################################
# Created by write_sdc
###############################################################################
current_design contador
###############################################################################
# Timing Constraints
###############################################################################
set_input_delay 1.0000 -add_delay [get_ports {enable}]
set_input_delay 1.0000 -add_delay [get_ports {suma_resta}]
set_output_delay 1.0000 -add_delay [get_ports {resultado[0]}]
set_output_delay 1.0000 -add_delay [get_ports {resultado[1]}]
set_output_delay 1.0000 -add_delay [get_ports {resultado[2]}]
set_output_delay 1.0000 -add_delay [get_ports {resultado[3]}]
set_false_path\
    -from [get_ports {reset}]
###############################################################################
# Environment
###############################################################################
###############################################################################
# Design Rules
###############################################################################
