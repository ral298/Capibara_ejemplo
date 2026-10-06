#!/usr/bin/env bash
set -euo pipefail

# Uso:
#   ./img2gds.sh imagen.png nombre_top
#   ./img2gds.sh imagen.png nombre_top carpeta_salida
#
# Limitar una sola dimensión física y conservar relación de aspecto:
#   ./img2gds.sh imagen.png nombre_top --max-width 191
#   ./img2gds.sh imagen.png nombre_top --max-height 400
#
# También se puede indicar carpeta:
#   ./img2gds.sh imagen.png nombre_top carpeta_salida --max-width 191
#
# IMPORTANTE:
#   --max-width y --max-height son mutuamente excluyentes.

if [ "$#" -lt 2 ]; then
    echo "Uso:"
    echo "  $0 <imagen> <nombre_top> [carpeta_salida] [--max-width um | --max-height um]"
    echo ""
    echo "Ejemplos:"
    echo "  $0 ipn_logo.png ipn_logo"
    echo "  $0 ipn_logo.png ipn_logo --max-width 191"
    echo "  $0 ipn_logo.png ipn_logo --max-height 400"
    echo "  $0 ipn_logo.png ipn_logo build_ipn --max-width 191"
    exit 1
fi

IMAGE="$1"
TOP="$2"
shift 2

OUTPUT_DIR="$TOP"
OUTPUT_SET=0
MAX_WIDTH=""
MAX_HEIGHT=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        --max-width)
            if [ "$#" -lt 2 ]; then
                echo "ERROR: --max-width requiere un valor en um." >&2
                exit 1
            fi
            MAX_WIDTH="$2"
            shift 2
            ;;

        --max-height)
            if [ "$#" -lt 2 ]; then
                echo "ERROR: --max-height requiere un valor en um." >&2
                exit 1
            fi
            MAX_HEIGHT="$2"
            shift 2
            ;;

        -*)
            echo "ERROR: Opción desconocida: $1" >&2
            exit 1
            ;;

        *)
            if [ "$OUTPUT_SET" -eq 1 ]; then
                echo "ERROR: Solo se permite una carpeta de salida." >&2
                exit 1
            fi

            OUTPUT_DIR="$1"
            OUTPUT_SET=1
            shift
            ;;
    esac
done

if [ -n "$MAX_WIDTH" ] && [ -n "$MAX_HEIGHT" ]; then
    echo "ERROR: Usa solo --max-width o --max-height, no ambos." >&2
    exit 1
fi

if [ ! -f "$IMAGE" ]; then
    echo "ERROR: No existe la imagen: $IMAGE" >&2
    exit 1
fi

# El nombre se usa como celda GDS, macro LEF, celda Liberty y módulo Verilog.
if [[ ! "$TOP" =~ ^[A-Za-z_][A-Za-z0-9_\$]*$ ]]; then
    echo "ERROR: Nombre TOP inválido: $TOP" >&2
    echo "Usa letras, números, '_' o '$', comenzando con letra o '_'." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_ABS="$(realpath "$IMAGE")"

mkdir -p "$OUTPUT_DIR"
OUTPUT_ABS="$(realpath "$OUTPUT_DIR")"

export IMG2GDS_IMAGE="$IMAGE_ABS"
export IMG2GDS_TOP="$TOP"
export IMG2GDS_OUTPUT="$OUTPUT_ABS"
export IMG2GDS_MAX_WIDTH="$MAX_WIDTH"
export IMG2GDS_MAX_HEIGHT="$MAX_HEIGHT"

echo "Imagen : $IMG2GDS_IMAGE"
echo "TOP    : $IMG2GDS_TOP"
echo "Salida : $IMG2GDS_OUTPUT"

if [ -n "$MAX_WIDTH" ]; then
    echo "Max W  : ${MAX_WIDTH} um"
fi

if [ -n "$MAX_HEIGHT" ]; then
    echo "Max H  : ${MAX_HEIGHT} um"
fi

echo ""

# Se ejecuta mediante KLayout para garantizar disponibilidad de pya.
klayout -b -r "$SCRIPT_DIR/img2gds_terminal.py"

echo ""
echo "Archivos creados:"
echo "  $OUTPUT_ABS/$TOP.gds"
echo "  $OUTPUT_ABS/$TOP.lef"
echo "  $OUTPUT_ABS/$TOP.lib"
echo "  $OUTPUT_ABS/$TOP.vh"
