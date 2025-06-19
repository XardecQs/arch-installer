#!/usr/bin/bash
# Verificaciones iniciales

print_step "Verificando requisitos previos"

# Cargar librerías
source "${BASE_DIR}/lib/validation.sh"

# Verificaciones básicas
check_root
check_uefi

# Mostrar discos disponibles
echo -e "${GREEN}Discos disponibles:${NC}"
lsblk -d -e 7,11 -o NAME,SIZE,TYPE | grep "disk"
echo ""

# Solicitar disco
echo -e "${YELLOW}Ingresa el nombre del disco (ej: sda, vda):${NC}"
read -rp "Disco: " disk_name
DISK="/dev/$disk_name"

# Advertencia de borrado
echo -e "\n${RED}¡ADVERTENCIA!${NC}"
echo -e "${YELLOW}Esta operación borrará TODOS los datos en ${DISK}${NC}"
echo -e "${YELLOW}No podrás recuperar ningún archivo después de continuar${NC}\n"

if ! read -rp "¿Estás completamente seguro de continuar? (escribe 'SI' en mayúsculas): " CONFIRM
then
    error_exit "Instalación cancelada por el usuario."
fi

if [[ "$CONFIRM" != "SI" ]]; then
    error_exit "No se confirmó la operación. Instalación cancelada."
fi

# Verificar disco
check_disk

# Configurar hora
print_step "Configurando hora automática"
timedatectl set-ntp true
check_clock_sync