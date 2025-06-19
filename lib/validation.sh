#!/usr/bin/env bash
check_root() {
    [[ $(id -u) -eq 0 ]] || error_exit "Ejecutar como root"
}

check_uefi() {
    [[ -d /sys/firmware/efi ]] || error_exit "Solo soporta UEFI"
}

check_disk() {
    [[ -b "$DISK" ]] || error_exit "Disco $DISK no existe"
}

check_clock_sync() {
    if timedatectl | grep -q "System clock synchronized: yes"; then
        echo -e "${GREEN}Reloj del sistema sincronizado${NC}"
    else
        echo -e "${YELLOW}Advertencia: Reloj del sistema no sincronizado${NC}"
    fi
}