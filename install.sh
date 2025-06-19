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
for module in {01..09}; do
    module_file="${BASE_DIR}/modules/${module}-*.sh"
    if [[ -f $module_file ]]; then
        print_step "Ejecutando módulo: ${module_file##*/}"
        source "$module_file"
    fi
done

print_step "Instalación completada con éxito!"
echo -e "${YELLOW}El sistema se reiniciará en 10 segundos...${NC}"
sleep 10
shutdown -r now