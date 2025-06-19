#!/usr/bin/env bash
# Instalación base

print_step "Instalando sistema base"
pacstrap /mnt $PACKAGES

print_step "Generando fstab"
genfstab -U /mnt > /mnt/etc/fstab

# Aplicar opciones de seguridad a /tmp
print_step "Aplicando opciones de seguridad a /tmp"
sed -i '/subvol=@tmp/s/defaults/defaults,noexec,nosuid,nodev/' /mnt/etc/fstab