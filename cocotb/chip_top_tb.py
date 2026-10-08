# SPDX-FileCopyrightText: © 2025 Project Template Contributors
# SPDX-License-Identifier: Apache-2.0

import os
import random
import logging
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, Edge, RisingEdge, FallingEdge, ClockCycles
from cocotb_tools.runner import get_runner

sim = os.getenv("SIM", "icarus")
gl = os.getenv("GL", False)
pdk_root = os.getenv("PDK_ROOT", Path(__file__).resolve().parent / "../gf180mcu")
pdk = os.getenv("PDK", "gf180mcuD")
scl = os.getenv("SCL", "gf180mcu_as_sc_mcu7t3v3")
pad = os.getenv("PAD", "gf180mcu_ocd_io")
sram = os.getenv("SRAM", "gf180mcu_ocd_ip_sram")
slot = os.getenv("SLOT", "1x0p5")

hdl_toplevel = "chip_top"

# 100 MHz -> 10 ns
CLK_PERIOD_NS = 10


def set_bidir_inputs(dut, enable, suma_resta):
    """
    bidir_PAD[0] = enable
    bidir_PAD[1] = suma_resta
    bidir_PAD[NUM_BIDIR_PADS-1:2] = Z
    """
    from cocotb.types import LogicArray

    num_bidir = len(dut.bidir_PAD)

    valor = (
        "Z" * (num_bidir - 2) +
        str(int(suma_resta)) +
        str(int(enable))
    )

    dut.bidir_PAD.value = LogicArray(valor)


async def comprobar_salida(dut, esperado, mensaje=""):
    await RisingEdge(dut.clk_PAD)
    await FallingEdge(dut.clk_PAD)

    valor = dut.bidir_PAD.value[5:2]

    if not valor.is_resolvable:
        raise AssertionError(
            f"{mensaje} | bidir_PAD[5:2] contiene X/Z: {valor}"
        )

    obtenido = int(valor)

    assert obtenido == esperado, (
        f"{mensaje} | Esperado = {esperado:04b} ({esperado}), "
        f"Obtenido = {obtenido:04b} ({obtenido})"
    )

    dut._log.info(
        f"{mensaje}: salida = {obtenido:04b} ({obtenido})"
    )


@cocotb.test()
async def test_contador(dut):

    # ---------------------------------------------------------
    # Inicialización
    # reset es ACTIVO EN BAJO
    # ---------------------------------------------------------
    dut.clk_PAD.value = 0
    dut.rst_n_PAD.value = 0
    dut.input_PAD.value = 0

    if gl:
        dut.VDD.value = 1
        dut.VSS.value = 0

    set_bidir_inputs(
        dut,
        enable=0,
        suma_resta=1
    )

    await Timer(1, unit="ns")

    cocotb.start_soon(
        Clock(dut.clk_PAD, CLK_PERIOD_NS, unit="ns").start(start_high=False)
    )

    # ---------------------------------------------------------
    # RESET
    # ---------------------------------------------------------
    await comprobar_salida(dut, 0, "RESET ciclo 1")
    await comprobar_salida(dut, 0, "RESET ciclo 2")

    # Liberar reset
    dut.rst_n_PAD.value = 1

    # ---------------------------------------------------------
    # ENABLE = 0 -> mantener valor
    # ---------------------------------------------------------
    for i in range(3):
        await comprobar_salida(
            dut,
            0,
            f"ENABLE=0 ciclo {i + 1}"
        )

    # ---------------------------------------------------------
    # CONTEO ASCENDENTE
    # suma_resta = 1 -> +1
    # ---------------------------------------------------------
    set_bidir_inputs(
        dut,
        enable=1,
        suma_resta=1
    )

    dut._log.info("---- CONTEO ASCENDENTE ----")

    for esperado in range(1, 16):
        await comprobar_salida(dut, esperado, "SUMA")

    # 1111 + 0001 -> 0000
    await comprobar_salida(
        dut,
        0,
        "SUMA con overflow"
    )

    # ---------------------------------------------------------
    # CONTEO DESCENDENTE
    # suma_resta = 0 -> +1111 = -1 en complemento a 2
    # ---------------------------------------------------------
    set_bidir_inputs(
        dut,
        enable=1,
        suma_resta=0
    )

    dut._log.info("---- CONTEO DESCENDENTE ----")

    for esperado in range(15, -1, -1):
        await comprobar_salida(dut, esperado, "RESTA")

    # ---------------------------------------------------------
    # ENABLE = 0 -> HOLD
    # ---------------------------------------------------------
    set_bidir_inputs(
        dut,
        enable=0,
        suma_resta=0
    )

    for i in range(3):
        await comprobar_salida(
            dut,
            0,
            f"HOLD ciclo {i + 1}"
        )

    # ---------------------------------------------------------
    # Volver a contar antes del reset final
    # ---------------------------------------------------------
    set_bidir_inputs(
        dut,
        enable=1,
        suma_resta=1
    )

    for esperado in range(1, 6):
        await comprobar_salida(
            dut,
            esperado,
            "SUMA antes de RESET"
        )

    # ---------------------------------------------------------
    # RESET ASÍNCRONO ACTIVO EN BAJO
    # ---------------------------------------------------------
    dut.rst_n_PAD.value = 0

    # Esperar propagación del reset a través del pad,
    # pero menos de medio periodo del reloj.
    await Timer(3, unit="ns")

    valor = dut.bidir_PAD.value[5:2]

    if not valor.is_resolvable:
        raise AssertionError(
            f"RESET asíncrono | bidir_PAD[5:2] contiene X/Z: {valor}"
        )

    assert int(valor) == 0, (
        f"RESET asíncrono | Esperado 0000, obtenido {valor}"
    )

    dut._log.info("RESET asíncrono: salida = 0000 (0)")

    # Liberar reset
    dut.rst_n_PAD.value = 1

    set_bidir_inputs(
        dut,
        enable=0,
        suma_resta=1
    )

    dut._log.info(
        "TEST PASSED: reset asíncrono, enable, suma, resta y overflow funcionan correctamente."
    )

    from cocotb.types import LogicArray

    bv = LogicArray("0101")
    dut._log.info("===============================================================")
    dut._log.info("bv.get_value(): " + str(bv))
    dut._log.info("bv.integer: " + str(bv))
    dut._log.info("===============================================================")

    bv = LogicArray.from_unsigned(7, 4)
    dut._log.info("===============================================================")
    dut._log.info("bv.get_value(): " + str(bv))
    dut._log.info("bv.integer: " + str(bv))
    dut._log.info("===============================================================")

    bv = LogicArray("ZZZ1")
    dut._log.info("bv.get_value(): " + str(bv))
    dut._log.info("bv.integer: " + str(bv))
    dut._log.info("===============================================================")


def chip_top_runner():

    proj_path = Path(__file__).resolve().parent

    sources = []
    defines = {f"SLOT_{slot.upper()}": True}
    includes = [proj_path / "../src/"]

    # Set the LibreLane PDK/SCL/PAD defines
    defines[f"PDK_{pdk.replace('-','_')}"] = True
    defines[f"SCL_{scl}"] = True
    defines[f"PAD_{pad}"] = True
    defines[f"SRAM_{sram}"] = False

    if gl:
        # SCL models
        sources.append(Path(pdk_root) / pdk / "libs.ref" / scl / "verilog" / f"{scl}.v")
        if scl != "gf180mcu_as_sc_mcu7t3v3":
            sources.append(Path(pdk_root) / pdk / "libs.ref" / scl / "verilog" / "primitives.v")

        # We use the powered netlist
        sources.append(proj_path / f"../final/pnl/{hdl_toplevel}.pnl.v")
        sources.append(proj_path / f"../librelane/build/contador/pnl/contador.pnl.v")
        
        print(Path(pdk_root) / pdk / "libs.ref" / scl / "verilog" / f"{scl}.v","==================")
        
        
        
        

        defines.update({"FUNCTIONAL": True, "USE_POWER_PINS": True})
    else:
        sources.append(proj_path / "../src/chip_top.sv")
        sources.append(proj_path / "../src/chip_core.sv")
        sources.append(proj_path / "../src/contador/contador.v")

    sources += [
        # IO pad models
        Path(pdk_root) / pdk / f"libs.ref/{pad}/verilog/{pad}.v",
        
        # SRAM macros
        Path(pdk_root) / pdk / f"libs.ref/{sram}/verilog/{sram}__sram512x8m8wm1.v",
        
        # Custom IP
        proj_path / "../ip/gf180mcu_ws_ip__logo/vh/gf180mcu_ws_ip__logo.v",
        proj_path / "../ip/gf180mcu_ws_ip__marker/vh/gf180mcu_ws_ip__marker.v",
        proj_path / "../ip/gf180mcu_ws_ip__qrcode_id/vh/gf180mcu_ws_ip__qrcode_id.v",
        proj_path / "../ip/gf180mcu_ws_ip__shuttle_id/vh/gf180mcu_ws_ip__shuttle_id.v",
        proj_path / "../ip/gf180mcu_ws_ip__project_id/vh/gf180mcu_ws_ip__project_id.v",
        #proj_path / "../ip/analog_connect/analog_connect.vh",
        
        #Logods el laboratorio
        #proj_path / "../librelane/build/capibara/capibara.vh",
        proj_path / "../librelane/build/cic/cic.vh",
        proj_path / "../librelane/build/ipn_logo/ipn_logo.v"

    ]

    build_args = []

    if sim == "icarus":
        # For debugging
        # build_args = ["-Winfloop", "-pfileline=1"]
        pass

    if sim == "verilator":
        build_args = ["--timing", "--trace", "--trace-fst", "--trace-structs", "--DUSE_POWER_PINS"]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel=hdl_toplevel,
        defines=defines,
        always=True,
        includes=includes,
        build_args=build_args,
        waves=True
    )

    plusargs = []

    runner.test(
        hdl_toplevel=hdl_toplevel,
        test_module="chip_top_tb,",
        plusargs=plusargs,
        waves=True
    )


if __name__ == "__main__":
    chip_top_runner()
