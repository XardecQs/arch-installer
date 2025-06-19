#!/usr/bin/env bash
HOSTNAME="arch-pc"
TIMEZONE="America/Lima"
KEYMAP="la-latin1"
LANG="es_PE.UTF-8"
# Tamaño en MiB
EFI_SIZE="513"
BOOT_SIZE="1024"
# Variables calculadas
DISK=""
USERNAME=""
SWAP_SIZE=""
TOTAL_SIZE=""
ROOT_END=""
# Paquetes a instalar
PACKAGES="base base-devel linux linux-firmware networkmanager grub wpa_supplicant efibootmgr zsh nvim git openssh os-prober"