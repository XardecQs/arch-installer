#!/bin/bash
# Particionado y formateo

print_step "Particionando disco $DISK"

# Calcular tamaños
TOTAL_SIZE=$(parted -s "$DISK" unit MiB print | grep "Disk /" | awk '{print $3}' | tr -d 'MiB')
SWAP_SIZE=$(get_ram_size) # Tamaño swap = RAM en MiB
ROOT_END=$((TOTAL_SIZE - SWAP_SIZE))

# Crear particiones
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart "EFI" fat32 1MiB "${EFI_SIZE}MiB"
parted -s "$DISK" set 1 esp on
parted -s "$DISK" mkpart "BOOT" ext4 "${EFI_SIZE}MiB" "$((EFI_SIZE + BOOT_SIZE))MiB"
parted -s "$DISK" mkpart "ROOT" btrfs "$((EFI_SIZE + BOOT_SIZE))MiB" "${ROOT_END}MiB"
parted -s "$DISK" mkpart "SWAP" linux-swap "${ROOT_END}MiB" 100%

# Formatear particiones
print_step "Formateando particiones"
mkfs.fat -F32 "${DISK}1"
mkfs.ext4 -F "${DISK}2"
mkfs.btrfs -f "${DISK}3"
mkswap "${DISK}4"
swapon "${DISK}4"

# Configurar subvolúmenes Btrfs
print_step "Configurando subvolúmenes Btrfs"
mount "${DISK}3" /mnt
cd /mnt
btrfs subvolume create @
btrfs subvolume create @home
btrfs subvolume create @tmp
cd /
umount /mnt

# Montar subvolúmenes
print_step "Montando subvolúmenes"
mount -o rw,subvol=@,space_cache=v2 "${DISK}3" /mnt
mkdir -p /mnt/{boot,home,tmp}

# Asegurar que /boot esté montado antes de crear /boot/efi
mount "${DISK}2" /mnt/boot
mkdir -p /mnt/boot/efi
mount "${DISK}1" /mnt/boot/efi

mount -o rw,subvol=@home,space_cache=v2 "${DISK}3" /mnt/home
mount -o rw,subvol=@tmp,space_cache=v2 "${DISK}3" /mnt/tmp

# Verificar montaje de EFI
print_step "Verificando montaje de EFI"
if ! mount | grep -q "${DISK}1"; then
    error_exit "La partición EFI no está montada correctamente"
fi