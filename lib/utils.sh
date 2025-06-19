#!/usr/bin/env bash
print_step() {
    echo -e "${GREEN}[+] ${BLUE}$1${NC}"
}

confirm_action() {
    echo -e "${YELLOW}$1${NC}"
    read -rp "¿Continuar? (y/N): " resp
    [[ "$resp" =~ ^[Yy]$ ]] || return 1
    return 0
}

error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        error_exit "Comando '$1' no encontrado"
    fi
}

get_ram_size() {
    free -m | awk '/Mem:/ {print $2}'
}