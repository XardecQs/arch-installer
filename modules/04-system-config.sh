#!/bin/bash
# Configuración del sistema

print_step "Preparando configuración post-instalación"

# Crear script de configuración en chroot
cat << 'EOF' > /mnt/arch-chroot.sh
#!/bin/bash
set -euo pipefail

# Variables
BASE_DIR="/arch-installer"
source "${BASE_DIR}/lib/colors.sh"
source "${BASE_DIR}/lib/utils.sh"
source "${BASE_DIR}/lib/config.sh"

# Ejecutar módulos de configuración
for module in {05..09}; do
    module_file="${BASE_DIR}/modules/${module}-*.sh"
    if [[ -f $module_file ]]; then
        print_step "Ejecutando: ${module_file##*/}"
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