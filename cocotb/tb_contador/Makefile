# ==============================================================================
# Makefile para el Chipathon - Acelerador de Convolución (50 MHz)
# ==============================================================================

# Simulador por defecto y lenguaje
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Dirección de tus archivos fuentes lógicos
SRC_DIR = $(PWD)/../../src/contador

# Lista completa de tus 10 archivos de diseño (sin el timescale/tb)
PROJECT_SOURCES = contador.v 

ifneq ($(GATES),yes)

# ------------------------------------------------------------------------------
# Configuración para Simulación RTL (Pre-Síntesis)
# ------------------------------------------------------------------------------
SIM_BUILD        = $(PWD)
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
VERILOG_SOURCES += $(PWD)/tb.v
else

# ------------------------------------------------------------------------------
# Configuración para Simulación Gate-Level (GL / Post-Síntesis)
# ------------------------------------------------------------------------------
SIM_BUILD        = sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1

# Modelos del PDK correspondientes a tu entorno de la fundición
VERILOG_SOURCES += $(PWD)/../../gf180mcu/gf180mcuD/libs.ref/gf180mcu_as_sc_mcu7t3v3/verilog/gf180mcu_as_sc_mcu7t3v3.v


# Netlist sintetizado final del proyecto
VERILOG_SOURCES += $(PWD)/../../librelane/build/contador/pnl/contador.pnl.v
VERILOG_SOURCES += $(PWD)/tb_gls.v
endif

# Permitir compartir configuraciones vía `include` si es necesario
COMPILE_ARGS    += -I$(SRC_DIR)

# Incluir el archivo de testbench puente (el que tiene el dumper de ondas)

TOPLEVEL = tb

# Nombre de tu archivo de python (test_con32_cocotb.py sin el .py)
MODULE = test

# Incluye las reglas oficiales de cocotb para configurar el simulador
include $(shell cocotb-config --makefiles)/Makefile.sim
