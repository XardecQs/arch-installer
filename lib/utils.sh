#!/usr/bin/env bash

# Funciones de logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_debug() {
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
}

# Función para mostrar banner
show_banner() {
    clear
    echo -e "${YELLOW}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════╗
    ║            INSTALADOR MODULAR DE ARCH LINUX           ║
    ║                     UEFI + BTRFS                      ║
    ╚═══════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Función para mostrar mensaje de finalización
show_completion_message() {
    echo -e "${GREEN}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════╗
    ║           ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!       ║
    ╚═══════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Función para confirmar acciones peligrosas
confirm_dangerous_action() {
    local message="$1"
    local confirmation_text="$2"
    
    echo -e "\n${RED}¡ADVERTENCIA CRÍTICA!${NC}"
    echo -e "${YELLOW}$message${NC}"
    echo -e "\n${YELLOW}Para continuar, escribe exactamente: '$confirmation_text'${NC}"
    
    local user_input
    read -rp "Confirmación: " user_input
    
    if [[ "$user_input" != "$confirmation_text" ]]; then
        log_error "Confirmación incorrecta. Operación cancelada"
        exit 1
    fi
}

# Función para crear directorio con verificación
safe_mkdir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" || {
            log_error "No se pudo crear directorio: $dir"
            exit 1
        }
    fi
}