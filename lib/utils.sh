#!/usr/bin/env bash
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
CYAN='\e[1;36m'
NC='\e[0m'

ms_green() {
    echo -e "${GREEN}$1${NC}"
}

ms_yellow() {
    echo -e "${YELLOW}$1${NC}"
}

ms_red() {
    echo -e "${RED}$1${NC}"
}

ms_cyan() {
    echo -e "${CYAN}$1${NC}"
}

ms_blue() {
    echo -e "${BLUE}$1${NC}"
}


log_debug() {
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
}

show_banner() {
    clear
    echo -e "${YELLOW}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════╗
    ║          INSTALADOR DE ARCH LINUX DE XAVIER           ║
    ║                     UEFI + BTRFS                      ║
    ╚═══════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_completion_message() {
    echo -e "${GREEN}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════╗
    ║           ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!       ║
    ╚═══════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

confirm_action() {
    local message="${1:-"¿Quieres continuar?"}"
    local mode="${2:-S}"
    local user_input
    
    if [[ "$mode" = "S" ]]; then
        read -rp "$message [S/n]: " user_input
        user_input="${user_input:-S}"
    else
        read -rp "$message [s/N]: " user_input
        user_input="${user_input:-N}"
    fi
    
    user_input=$(echo "$user_input" | tr '[:lower:]' '[:upper:]')
    
    if [[ "$user_input" != "S" ]]; then
        ms_red "Operación cancelada, saliendo..."
        exit 1
    fi
    echo ""
}

confirm_dangerous_action() {
    local message="$1"
    local confirmation_text="$2"
    
    echo -e "\n${RED}¡ADVERTENCIA CRÍTICA!${NC}"
    echo -e "$message"
    echo -e "\n${YELLOW}Para continuar, escribe exactamente: '$confirmation_text'${NC}"
    
    local user_input
    read -rp "Confirmación: " user_input
    
    if [[ "$user_input" != "$confirmation_text" ]]; then
        ms_red "Confirmación incorrecta. Operación cancelada"
        exit 1
    fi
}

safe_mkdir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" || {
            log_error "No se pudo crear directorio: $dir"
            exit 1
        }
    fi
}

select_disk() {
    ms_green "Discos disponibles:"
    lsblk -d -e 7,11 -o NAME,SIZE,TYPE | grep "disk"
    echo ""
    ms_yellow "Ingresa el nombre del disco (ej: sda, vda):"
    read -rp "Disco: " DISK
    DISK="/dev/$DISK"
    if [[ ! -b "$DISK" ]]; then
        echo ""
        ms_red "El disco $DISK no existe, por favor, elige otro:"
        echo ""
        select_disk
    fi
}

initial_disclaimer() {
    echo -e "$(ms_yellow "ATENCIÓN:") Este script automatizará la instalación de Arch Linux según mis preferencias personales.
1. Se utilizará el DISCO COMPLETO seleccionado, eliminando TODOS los datos existentes.
2. Se creará una nueva tabla de particiones (GPT).
3. Se crearán 4 particiones:
   - boot (ext4) - $EFI_SIZE MiB
   - swap - Igual al tamaño de tu RAM
   - raíz (btrfs) - Ocupará el resto del espacio
   - home (subvolumen btrfs dentro de raíz)
    "
    echo -e "Asegúrese de editar el archivo de configuración ($(ms_green lib/config.sh)) antes de iniciar este script.\n"
    ms_green "La configuración actual es:"
    
    echo -e "$(ms_cyan HOSTNAME): $HOSTNAME"
    echo -e "$(ms_cyan TIMEZONE): $TIMEZONE"
    echo -e "$(ms_cyan KEYMAP): $KEYMAP"
    echo -e "$(ms_cyan LANG): $LANG"
    echo -e "$(ms_cyan EFI_SIZE): $EFI_SIZE MiB"
    echo -e "$(ms_cyan BOOT_SIZE): $BOOT_SIZE MiB"
    echo ""
    confirm_action "¿Quieres continuar con la configuración actual?" "n"
}