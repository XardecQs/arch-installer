#!/bin/bash
# Instalación de GRUB

print_step "Instalando gestor de arranque"

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="ArchLinux"

# Configurar GRUB
sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub
sed -i 's/#GRUB_SAVEDEFAULT/GRUB_SAVEDEFAULT/' /etc/default/grub
echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg