import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer

# 100 MHz -> 10 ns
CLK_PERIOD_NS = 10


async def comprobar_salida(dut, esperado, mensaje=""):
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)

    valor = dut.suma_out.value #Valor binario

    if not valor.is_resolvable:
        raise AssertionError(
            f"{mensaje} | suma_out contiene X/Z: {valor}"
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

















    cocotb.start_soon(
        Clock(dut.clk, CLK_PERIOD_NS, unit="ns").start(start_high=False)
    )

    # ---------------------------------------------------------
    # RESET
    # ---------------------------------------------------------
    await comprobar_salida(dut, 0, "RESET ciclo 1")
    await comprobar_salida(dut, 0, "RESET ciclo 2")




    # Liberar reset
    
    
    
    
    
    
    

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
    dut.enable.value = 1
    dut.suma_resta.value = 1

    dut._log.info("---- CONTEO ASCENDENTE ----")

    for esperado in range(1, 16):
        # hacer que cuente con la funcion comprobar_salida, que vaya comparando con esperado

        





    # 1111 + 0001 -> 0000
    #sumarle un 1 para que llegue a 0
    










    # ---------------------------------------------------------
    # CONTEO DESCENDENTE
    # suma_resta = 0 -> +1111 = -1 en complemento a 2
    # ---------------------------------------------------------
    dut.suma_resta.value = 0

    dut._log.info("---- CONTEO DESCENDENTE ----")

    for esperado in range(15, -1, -1):

        #que cuente de manera decendente y haga la comparación con esperado
        










    # ---------------------------------------------------------
    # ENABLE = 0 -> HOLD
    # ---------------------------------------------------------
    dut.enable.value = 0

    for i in range(3):
        #que intente contar y al no poder contar por enable=0 siempre tiene que esperar un 0
        
        








        
    # ---------------------------------------------------------
    # Volver a contar antes del reset final
    # ---------------------------------------------------------
    dut.enable.value = 1
    dut.suma_resta.value = 1

    for esperado in range(1, 6):
        await comprobar_salida(
            dut,
            esperado,
            "SUMA antes de RESET"
        )

    # ---------------------------------------------------------
    # RESET ASÍNCRONO ACTIVO EN BAJO
    # ---------------------------------------------------------
    dut.rst.value = 0

    # Como es reset asíncrono, no necesita esperar al flanco de reloj.
    await Timer(1, unit="ns")

    valor = dut.suma_out.value

    if not valor.is_resolvable:
        raise AssertionError(
            f"RESET asíncrono | suma_out contiene X/Z: {valor}"
        )

    assert int(valor) == 0, (
        f"RESET asíncrono | Esperado 0000, obtenido {valor}"
    )

    dut._log.info("RESET asíncrono: salida = 0000 (0)")

    # Liberar reset
    dut.rst.value = 1
    dut.enable.value = 0

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
