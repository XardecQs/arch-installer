#!/bin/bash
# Instalación de GRUB

print_step "Instalando gestor de arranque"

# Verificar montaje de EFI antes de instalar GRUB
if ! mount | grep -q '/boot/efi'; then
    error_exit "ERROR: /boot/efi no está montado. Verifica la partición EFI."
fi

# Verificar existencia del directorio EFI
if [[ ! -d "/boot/efi" ]]; then
    print_step "Creando directorio /boot/efi"
    mkdir -p /boot/efi
fi

# Instalar GRUB
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="ArchLinux"

# Configurar GRUB
sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub
sed -i 's/#GRUB_SAVEDEFAULT/GRUB_SAVEDEFAULT/' /etc/default/grub
echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Verificar instalación
if [[ $? -ne 0 ]]; then
    error_exit "Error al instalar GRUB. Verifica los mensajes anteriores."
fi