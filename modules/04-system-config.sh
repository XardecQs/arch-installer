#!/bin/bash
# Configuración del sistema (04-system-config.sh)

print_step "Preparando configuración post-instalación"

# Crear script de configuración en chroot
cat << 'EOF' > /mnt/arch-chroot.sh
#!/bin/bash
set -euo pipefail

# Definir ruta base
BASE_DIR="/arch-installer"

# Cargar librerías
source "${BASE_DIR}/lib/colors.sh"
source "${BASE_DIR}/lib/utils.sh"
source "${BASE_DIR}/lib/config.sh"

# Lista de módulos internos (para chroot)
MODULES=(
    "05-users"
    "06-bootloader"
    "07-services"
    "08-desktop"
    "09-finalize"
)

# Ejecutar módulos de configuración
for module in "${MODULES[@]}"; do
    module_file="${BASE_DIR}/modules/${module}.sh"
    if [[ -f "$module_file" ]]; then
        print_step "CHROOT: Ejecutando ${module}.sh"
        source "$module_file"
    fi
done
EOF

# Copiar toda la estructura al sistema nuevo
print_step "Copiando archivos de instalación"
mkdir -p /mnt/arch-installer
cp -r "${BASE_DIR}"/* /mnt/arch-installer/

# Dar permisos y ejecutar
chmod +x /mnt/arch-chroot.sh
print_step "Ingresando en chroot para configuración final"
arch-chroot /mnt /arch-chroot.sh