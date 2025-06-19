#!/usr/bin/env bash
set -euo pipefail

# Determinar ruta base del instalador
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Cargar librerías
source "${BASE_DIR}/lib/colors.sh"
source "${BASE_DIR}/lib/utils.sh"
source "${BASE_DIR}/lib/validation.sh"
source "${BASE_DIR}/lib/config.sh"

# Ejecutar módulos en orden
MODULES=(
    "01-prerequisites"
    "02-partitioning"
    "03-base-install"
    "04-system-config"
    "05-users"
    "06-bootloader"
    "07-services"
    "08-desktop"
    "09-finalize"
)

for module in "${MODULES[@]}"; do
    module_file="${BASE_DIR}/modules/${module}.sh"
    if [[ -f "$module_file" ]]; then
        print_step "Ejecutando módulo: ${module}.sh"
        source "$module_file"
    else
        error_exit "Módulo ${module}.sh no encontrado"
    fi
done

print_step "Instalación completada con éxito!"
echo -e "${YELLOW}El sistema se reiniciará en 10 segundos...${NC}"
sleep 10
shutdown -r now