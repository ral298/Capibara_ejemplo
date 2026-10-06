# -*- coding: utf-8 -*-
# -----------------------------------------------------------------------------
# KLayout Macro: Imagen -> Geometría GF180
# -----------------------------------------------------------------------------

import os
import pya


# ============================ GF180 layers ===================================

LAYER_DICT = {
    "metal1": (34, 0), "via1": (35, 0),
    "metal2": (36, 0), "via2": (38, 0),
    "metal3": (42, 0), "via3": (40, 0),
    "metal4": (46, 0), "via4": (41, 0),
    "metal5": (81, 0), "via5": (82, 0),
    "metaltop": (53, 0), "PR_bndry": (0, 0),
}


# =============================================================================
# FUNCIÓN PRINCIPAL
# =============================================================================

def Main():

    # =========================================================================
    # PARÁMETROS EDITABLES
    # =========================================================================

    # Imagen
    # Estos valores pueden recibirse desde img2gds.sh.
    # Si se ejecuta como macro de KLayout sin variables, conserva valores por defecto.
    imgSrc = os.environ.get(
        "IMG2GDS_IMAGE",
        "/foss/designs/CapiMagics/designs/macros_py/img/avatar.jpg"
    )

    # Raster
    pixel_um  = 0.76    # Tamaño de cada píxel convertido a geometría, en µm (0.76 µm × 0.76 µm)
    thresh    = 50     # Umbral de luminosidad (0–255) para decidir si un píxel se convierte en metal -128
    alpha_min = 10      # Transparencia mínima (0–255); píxeles con alfa menor se ignoran
    invert    = True    # Invierte la selección: True usa píxeles oscuros; False usa píxeles claros

    # Tamaño físico máximo opcional.
    # Solo se puede indicar uno para conservar la relación de aspecto.
    MAX_WIDTH_UM = os.environ.get("IMG2GDS_MAX_WIDTH", "")
    MAX_HEIGHT_UM = os.environ.get("IMG2GDS_MAX_HEIGHT", "")

    if MAX_WIDTH_UM and MAX_HEIGHT_UM:
        raise RuntimeError(
            "Usa solo --max-width o --max-height, no ambos."
        )

    # Correcciones geométricas
    FIX_DIAGONAL_CORNERS = True     # Corrige píxeles que se tocan únicamente por una esquina (patrones 10/01 y 01/10)
    FIX_ISOLATED_PIXELS  = True     # Elimina píxeles aislados y rellena huecos de un píxel completamente rodeados

    # Rango de metales
    METAL_START = 5     # Primera capa de metal donde se insertará la geometría (1–5)
    METAL_END   = 5     # Última capa de metal donde se insertará la geometría (1–5)

    # Slotting
    SLOTTING          = True    # Activa o desactiva la creación de ranuras verticales en el metal
    SLOT_METAL_PIXELS = 26      # Número de columnas de píxeles de metal entre ranuras
    SLOT_WIDTH_PIXELS = 1       # Ancho de cada ranura, expresado en columnas de píxeles

    # Layout
    DBU       = 0.001           # Unidad de resolución del layout en µm (0.001 µm = 1 nm)
    CELL_NAME = os.environ.get(
        "IMG2GDS_TOP",
        "img"
    )                           # Nombre de la celda principal del diseño

    # Directorio de salida. No modifica el algoritmo de conversión.
    OUTPUT_DIR = os.environ.get(
        "IMG2GDS_OUTPUT",
        CELL_NAME
    )

    # Capa temporal
    TEMP_LAYER    = 900         # Número de la capa auxiliar utilizada para construir la geometría
    TEMP_DATATYPE = 0           # Datatype de la capa auxiliar; se elimina junto con ella al finalizar


    # =========================================================================
    # CREAR LAYOUT
    # =========================================================================

    ly = pya.Layout()
    ly.dbu = DBU

    top = ly.create_cell(CELL_NAME)


    # =========================================================================
    # CARGAR IMAGEN
    # =========================================================================

    if not os.path.exists(imgSrc):
        raise RuntimeError(
            "No se encontró la imagen: %s" % imgSrc
        )

    img = pya.QImage(imgSrc)

    if img.isNull():
        raise RuntimeError(
            "KLayout no pudo cargar la imagen: %s" % imgSrc
        )

    img = img.convertToFormat(
        pya.QImage.Format_ARGB32
    )

    # -------------------------------------------------------------------------
    # LIMITAR TAMAÑO FÍSICO MÁXIMO CONSERVANDO LA RELACIÓN DE ASPECTO
    #
    # El algoritmo posterior no cambia: pixel_um sigue siendo el tamaño de
    # cada píxel de metal. Aquí solamente se reduce la resolución de entrada
    # cuando la imagen excede el ancho o alto físico solicitado.
    # -------------------------------------------------------------------------

    original_width_px = img.width()
    original_height_px = img.height()

    if MAX_WIDTH_UM:
        max_width_um = float(MAX_WIDTH_UM)

        if max_width_um <= 0:
            raise RuntimeError(
                "--max-width debe ser mayor que 0."
            )

        max_width_px = int(
            max_width_um / pixel_um
        )

        if max_width_px < 1:
            raise RuntimeError(
                "--max-width es menor que un píxel físico (%.3f um)." %
                pixel_um
            )

        if img.width() > max_width_px:
            img = img.scaledToWidth(
                max_width_px
            )

    elif MAX_HEIGHT_UM:
        max_height_um = float(MAX_HEIGHT_UM)

        if max_height_um <= 0:
            raise RuntimeError(
                "--max-height debe ser mayor que 0."
            )

        max_height_px = int(
            max_height_um / pixel_um
        )

        if max_height_px < 1:
            raise RuntimeError(
                "--max-height es menor que un píxel físico (%.3f um)." %
                pixel_um
            )

        if img.height() > max_height_px:
            img = img.scaledToHeight(
                max_height_px
            )

    width_px  = img.width()
    height_px = img.height()

    if MAX_WIDTH_UM or MAX_HEIGHT_UM:
        print(
            "Imagen original: %d x %d px" %
            (
                original_width_px,
                original_height_px
            )
        )

        print(
            "Imagen usada:    %d x %d px" %
            (
                width_px,
                height_px
            )
        )

        print(
            "Máximo raster:   %.3f um x %.3f um" %
            (
                width_px * pixel_um,
                height_px * pixel_um
            )
        )


    # =========================================================================
    # CONVERTIR IMAGEN A MATRIZ BINARIA
    # =========================================================================

    pixel_matrix = [
        [False for x in range(width_px)]
        for y in range(height_px)
    ]

    for y in range(height_px):

        for x in range(width_px):

            rgba = img.pixel(x, y)

            a = (rgba >> 24) & 0xff
            r = (rgba >> 16) & 0xff
            g = (rgba >> 8)  & 0xff
            b = rgba & 0xff

            if a < alpha_min:
                continue

            lum = (
                0.2126 * r +
                0.7152 * g +
                0.0722 * b
            )

            passed = (lum >= thresh)

            if invert:
                passed = not passed

            if passed:
                pixel_matrix[y][x] = True


    # =========================================================================
    # CORREGIR CONTACTOS DIAGONALES
    # =========================================================================

    pixel_matrix = FixDiagonalCorners(
        pixel_matrix,
        FIX_DIAGONAL_CORNERS
    )


    # =========================================================================
    # CORREGIR PÍXELES AISLADOS / HUECOS AISLADOS
    # =========================================================================

    pixel_matrix = FixIsolatedPixels(
        pixel_matrix,
        FIX_ISOLATED_PIXELS
    )


    # =========================================================================
    # CREAR CAPA TEMPORAL
    # =========================================================================

    temp_idx = ly.layer(
        pya.LayerInfo(
            TEMP_LAYER,
            TEMP_DATATYPE
        )
    )


    # =========================================================================
    # CONVERTIR MATRIZ A GEOMETRÍA
    # =========================================================================

    inserted = 0

    for y in range(height_px):

        for x in range(width_px):

            if not pixel_matrix[y][x]:
                continue

            px = pixel_um * x

            py = (
                pixel_um *
                (height_px - 1 - y)
            )

            top.shapes(temp_idx).insert(
                pya.DBox(
                    px,
                    py,
                    px + pixel_um,
                    py + pixel_um
                )
            )

            inserted += 1

    if inserted == 0:
        raise RuntimeError(
            "No se insertó ningún píxel."
        )


    # =========================================================================
    # CREAR REGIÓN
    # =========================================================================

    region = pya.Region(
        pya.RecursiveShapeIterator(
            ly,
            top,
            temp_idx
        )
    )

    if region.is_empty():
        raise RuntimeError(
            "La región quedó vacía tras rasterizar."
        )


    # =========================================================================
    # APLICAR SLOTTING
    # =========================================================================

    region = ApplyPixelAlignedSlotting(
        region,
        ly,
        SLOTTING,
        pixel_um,
        SLOT_METAL_PIXELS,
        SLOT_WIDTH_PIXELS
    )

    # =========================================================================
    # MOVER TODO EL DISEÑO AL ORIGEN (0, 0)
    # =========================================================================

    bbox = region.bbox()

    dx = -bbox.left
    dy = -bbox.bottom

    region = region.moved(
        pya.Vector(dx, dy)
    )

    # =========================================================================
    # CREAR PR_BNDRY
    # =========================================================================

    pr_bndry_idx = resolve_gf180(
        ly,
        "PR_bndry"
    )

    design_bbox = region.bbox()

    top.shapes(pr_bndry_idx).insert(
        design_bbox
    )

    # =========================================================================
    # COMPROBAR RANGO DE METALES
    # =========================================================================

    if not (
        1 <= METAL_START <= 5 and
        1 <= METAL_END <= 5 and
        METAL_START <= METAL_END
    ):
        raise RuntimeError(
            "Rango de metales inválido."
        )


    # =========================================================================
    # INSERTAR GEOMETRÍA EN METALES
    # =========================================================================

    for metal_number in range(
        METAL_START,
        METAL_END + 1
    ):

        metal_name = "metal%d" % metal_number

        layer_idx = resolve_gf180(
            ly,
            metal_name
        )

        top.shapes(layer_idx).insert(
            region
        )


    # =========================================================================
    # ELIMINAR CAPA TEMPORAL
    # =========================================================================

    top.shapes(temp_idx).clear()
    ly.delete_layer(temp_idx)


    # =========================================================================
    # GUARDAR RESULTADOS
    # =========================================================================

    os.makedirs(
        OUTPUT_DIR,
        exist_ok=True
    )

    gds_path = os.path.join(
        OUTPUT_DIR,
        "%s.gds" % CELL_NAME
    )

    lef_path = os.path.join(
        OUTPUT_DIR,
        "%s.lef" % CELL_NAME
    )

    lib_path = os.path.join(
        OUTPUT_DIR,
        "%s.lib" % CELL_NAME
    )

    vh_path = os.path.join(
        OUTPUT_DIR,
        "%s.vh" % CELL_NAME
    )

    # Guardar GDS generado por el algoritmo original.
    ly.write(gds_path)

    # El PR boundary ya fue generado a partir de design_bbox.
    # Usamos exactamente ese bbox para que el LEF coincida con el GDS.
    width_um = design_bbox.width() * ly.dbu
    height_um = design_bbox.height() * ly.dbu

    WriteLEF(
        lef_path,
        CELL_NAME,
        width_um,
        height_um,
        METAL_START,
        METAL_END
    )

    WriteLIB(
        lib_path,
        CELL_NAME
    )

    WriteVH(
        vh_path,
        CELL_NAME
    )

    print("")
    print("==============================================")
    print(" img2gds terminado")
    print("==============================================")
    print("TOP : %s" % CELL_NAME)
    print("IMG : %s" % imgSrc)
    print("SIZE: %.3f um x %.3f um" % (width_um, height_um))
    print("GDS : %s" % gds_path)
    print("LEF : %s" % lef_path)
    print("LIB : %s" % lib_path)
    print("VH  : %s" % vh_path)
    print("==============================================")
    print("")

    # En modo gráfico conserva el comportamiento original.
    # En ejecución batch (-b) simplemente no hay ventana que mostrar.
    try:
        mw = pya.MainWindow.instance()
        if mw is not None:
            DisplayLayout(ly)
            UpdateCurrentView()
    except Exception:
        pass


# =============================================================================
# FUNCIONES SECUNDARIAS
# =============================================================================


# ========================== Contar vecinos ===================================

def CountMetalNeighbors(matrix, x, y):

    height = len(matrix)
    width  = len(matrix[0])

    count = 0

    for dy in (-1, 0, 1):

        for dx in (-1, 0, 1):

            if dx == 0 and dy == 0:
                continue

            nx = x + dx
            ny = y + dy

            if (
                0 <= nx < width and
                0 <= ny < height and
                matrix[ny][nx]
            ):
                count += 1

    return count


# ===================== Corregir diagonales simples ===========================

def FixDiagonalCorners(matrix, enabled):

    if not enabled:
        return matrix

    height = len(matrix)
    width  = len(matrix[0])

    original = [
        row[:] for row in matrix
    ]

    result = [
        row[:] for row in matrix
    ]

    for y in range(height - 1):

        for x in range(width - 1):

            # A B
            # C D

            A = original[y][x]
            B = original[y][x + 1]
            C = original[y + 1][x]
            D = original[y + 1][x + 1]

            # 1 0
            # 0 1

            if A and D and not B and not C:

                score_B = CountMetalNeighbors(
                    original,
                    x + 1,
                    y
                )

                score_C = CountMetalNeighbors(
                    original,
                    x,
                    y + 1
                )

                if score_B >= score_C:
                    result[y][x + 1] = True
                else:
                    result[y + 1][x] = True


            # 0 1
            # 1 0

            elif B and C and not A and not D:

                score_A = CountMetalNeighbors(
                    original,
                    x,
                    y
                )

                score_D = CountMetalNeighbors(
                    original,
                    x + 1,
                    y + 1
                )

                if score_A >= score_D:
                    result[y][x] = True
                else:
                    result[y + 1][x + 1] = True

    return result


# ================= Corregir píxeles/huecos aislados ==========================

def FixIsolatedPixels(matrix, enabled):

    if not enabled:
        return matrix

    height = len(matrix)
    width  = len(matrix[0])

    original = [
        row[:] for row in matrix
    ]

    result = [
        row[:] for row in matrix
    ]

    # Necesitamos un borde de un píxel alrededor
    # del píxel central.
    for y in range(1, height - 1):

        for x in range(1, width - 1):

            center = original[y][x]

            neighbors = [
                original[y - 1][x - 1],
                original[y - 1][x],
                original[y - 1][x + 1],

                original[y][x - 1],
                original[y][x + 1],

                original[y + 1][x - 1],
                original[y + 1][x],
                original[y + 1][x + 1]
            ]

            # -------------------------------------------------------------
            # 000
            # 010
            # 000
            #
            # ->
            #
            # 000
            # 000
            # 000
            # -------------------------------------------------------------

            if center and not any(neighbors):

                result[y][x] = False


            # -------------------------------------------------------------
            # 111
            # 101
            # 111
            #
            # ->
            #
            # 111
            # 111
            # 111
            # -------------------------------------------------------------

            elif not center and all(neighbors):

                result[y][x] = True

    return result


# ============================== Slotting =====================================

def ApplyPixelAlignedSlotting(
    region,
    layout,
    enabled,
    pixel_um,
    metal_pixels,
    slot_width_pixels
):

    if not enabled or region.is_empty():
        return region

    if pixel_um <= 0:
        raise RuntimeError(
            "pixel_um debe ser mayor que 0."
        )

    if metal_pixels < 1:
        raise RuntimeError(
            "SLOT_METAL_PIXELS debe ser >= 1."
        )

    if slot_width_pixels < 1:
        raise RuntimeError(
            "SLOT_WIDTH_PIXELS debe ser >= 1."
        )

    pixel_db = int(
        round(
            pixel_um /
            layout.dbu
        )
    )

    metal_width_db = (
        metal_pixels *
        pixel_db
    )

    slot_width_db = (
        slot_width_pixels *
        pixel_db
    )

    period_db = (
        metal_width_db +
        slot_width_db
    )

    bbox = region.bbox()

    slots = pya.Region()

    x_slot = (
        bbox.left +
        metal_width_db
    )

    while x_slot < bbox.right:

        x1 = x_slot

        x2 = min(
            x_slot + slot_width_db,
            bbox.right
        )

        if x2 > x1:

            slots.insert(
                pya.Box(
                    x1,
                    bbox.bottom,
                    x2,
                    bbox.top
                )
            )

        x_slot += period_db

    result = (
        region -
        slots
    )

    result.merge()

    return result


# ========================== Generar archivos auxiliares =======================

def WriteLEF(
    filepath,
    cell_name,
    width_um,
    height_um,
    metal_start,
    metal_end
):
    lines = [
        "VERSION 5.7 ;",
        'BUSBITCHARS "[]" ;',
        'DIVIDERCHAR "/" ;',
        "",
        "MACRO %s" % cell_name,
        "  CLASS BLOCK ;",
        "  FOREIGN %s 0 0 ;" % cell_name,
        "  ORIGIN 0.000 0.000 ;",
        "  SIZE %.3f BY %.3f ;" % (width_um, height_um),
        "  SYMMETRY X Y ;",
        "",
        "  OBS",
    ]

    for metal_number in range(
        metal_start,
        metal_end + 1
    ):
        lines.extend([
            "    LAYER Metal%d ;" % metal_number,
            "      RECT 0.000 0.000 %.3f %.3f ;" % (
                width_um,
                height_um
            ),
        ])

    lines.extend([
        "  END",
        "END %s" % cell_name,
        "",
        "END LIBRARY",
        "",
    ])

    with open(
        filepath,
        "w",
        encoding="utf-8"
    ) as f:
        f.write("\n".join(lines))


def WriteLIB(
    filepath,
    cell_name
):
    content = """library (%s) {
  input_threshold_pct_fall: 50.0;
  input_threshold_pct_rise: 50.0;
  output_threshold_pct_fall: 50.0;
  output_threshold_pct_rise: 50.0;
  slew_lower_threshold_pct_fall: 20.0;
  slew_lower_threshold_pct_rise: 20.0;
  slew_upper_threshold_pct_fall: 80.0;
  slew_upper_threshold_pct_rise: 80.0;

  cell (%s) {
  }
}
""" % (
        cell_name,
        cell_name
    )

    with open(
        filepath,
        "w",
        encoding="utf-8"
    ) as f:
        f.write(content)


def WriteVH(
    filepath,
    cell_name
):
    content = """(* blackbox *)
module %s ();
endmodule
""" % cell_name

    with open(
        filepath,
        "w",
        encoding="utf-8"
    ) as f:
        f.write(content)


# ========================== Resolver capas ===================================

def resolve_gf180(layout, logical_name):

    if logical_name not in LAYER_DICT:

        raise RuntimeError(
            "No se pudo resolver la capa '%s'." %
            logical_name
        )

    layer, datatype = (
        LAYER_DICT[logical_name]
    )

    return layout.layer(
        pya.LayerInfo(
            layer,
            datatype
        )
    )


# ============================= Mostrar layout ================================

def DisplayLayout(layout):

    mw = pya.MainWindow.instance()

    vw = mw.view(
        mw.create_view()
    )

    vw.show_layout(
        layout,
        True
    )


def UpdateCurrentView():

    mw = pya.MainWindow.instance()

    cv = mw.current_view()

    cv.add_missing_layers()
    cv.max_hier_levels = 2
    cv.zoom_fit()


# =============================================================================
# EJECUTAR
# =============================================================================

if __name__ == "__main__":
    Main()
