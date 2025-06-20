#!/usr/bin/env bash
# set -euo pipefail

source lib/config.sh
source lib/utils.sh

if ! [ "$(id -u)" -eq 0 ]; then
    ms_red "Este script debe ser ejecutado como root, saliendo..."
    exit 1
fi

if [[ ! -d /sys/firmware/efi ]]; then
    ms_red "ERROR: Este sistema no tiene UEFI habilitado"
    echo "El script solo funciona con sistemas UEFI"
    exit 1
fi

#/────────────────────────────────────────────/#
# PARTICIONADO Y FORMATEO
#/────────────────────────────────────────────/#

show_banner
#initial_disclaimer
select_disk
#confirm_dangerous_action "Esta operación borrará TODOS los datos en $(ms_green $DISK) \nNo podrás recuperar ningún archivo después de continuar" "BORRAR TODOS LOS DATOS"
echo ""
echo -e "Instalando $(ms_blue "Arch Linux") en el disco $(ms_green $DISK)..."

ms_green "Configurando hora automática..."
timedatectl set-ntp true
ms_blue "Verificando sincronización del reloj:"
if timedatectl | grep -q "System clock synchronized: yes"; then
    ms_green "Reloj del sistema sincronizado correctamente"
else
    ms_yellow "Advertencia: El reloj del sistema no está sincronizado"
fi


#/────────────────────────────────────────────/#
# PARTICIONADO Y FORMATEO
#/────────────────────────────────────────────/#
ms_green "Creando particiones en $DISK..."

# Calcular tamaños
TOTAL_SIZE=$(parted -s "$DISK" unit MiB print | grep "$DISK" | awk '{print $3}' | tr -d 'MiB')
SWAP_SIZE=$(free -m | awk '/Mem:/ {print $2}') # Tamaño swap = RAM en MiB
ROOT_END=$((TOTAL_SIZE - SWAP_SIZE))

# Crear particiones
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart "EFI_System" fat32 1MiB "${EFI_SIZE}MiB"
parted -s "$DISK" set 1 esp on
parted -s "$DISK" mkpart "Arch_Boot" ext4 "${EFI_SIZE}MiB" "$((EFI_SIZE + BOOT_SIZE))MiB"
parted -s "$DISK" mkpart "Arch_Root" btrfs "$((EFI_SIZE + BOOT_SIZE))MiB" "${ROOT_END}MiB"
parted -s "$DISK" mkpart "Linux_Swap" linux-swap "${ROOT_END}MiB" 100%

# Formatear particiones
ms_green "Formateando particiones..."
mkfs.fat -F32 "${DISK}1"
mkfs.ext4 -F -L "Arch_Boot" "${DISK}2"
mkfs.btrfs -f -L "Arch_Linux" "${DISK}3"
mkswap "${DISK}4"
swapon "${DISK}4"

# Configurar subvolúmenes Btrfs
ms_green "Configurando subvolúmenes Btrfs..."
mount "${DISK}3" /mnt
cd /mnt
btrfs subvolume create @
btrfs subvolume create @home
btrfs subvolume create @tmp
cd /
umount /mnt

# Montar subvolúmenes
mount -o rw,subvol=@,compress=zstd,space_cache=v2 "${DISK}3" /mnt
mkdir -p /mnt/{boot,home,tmp}
mount "${DISK}2" /mnt/boot
mkdir -p /mnt/boot/efi
mount "${DISK}1" /mnt/boot/efi
mount -o rw,subvol=@home,compress=zstd,space_cache=v2 "${DISK}3" /mnt/home
mount -o rw,subvol=@tmp,space_cache=v2 "${DISK}3" /mnt/tmp

#/────────────────────────────────────────────/#
# INSTALAR SISTEMA BASE
#/────────────────────────────────────────────/#
ms_green "Instalando sistema base..."
pacstrap /mnt $PACKAGES

# Añadir opciones de seguridad a /tmp
ms_green "Aplicando opciones de seguridad a /tmp..."
mount -o remount,rw,noexec,nosuid,nodev,relatime,space_cache=v2,subvol=@tmp "${DISK}3" /tmp
genfstab -U /mnt > /mnt/etc/fstab

#/────────────────────────────────────────────/#
# CHROOT
#/────────────────────────────────────────────/#
# Dar permisos y ejecutar
chmod +x /mnt/arch-chroot.sh
ms_green "Ingresando en chroot para configuración final..."
arch-chroot /mnt /arch-chroot.sh

#/────────────────────────────────────────────/#
# FINALIZAR
#/────────────────────────────────────────────/#
echo -e "${GREEN}\nDesmontando particiones...${NC}"
umount -R /mnt
swapoff -a

echo -e "${GREEN}\n¡Instalación completada con éxito!${NC}"
echo -e "${YELLOW}El sistema se reiniciará en 10 segundos...${NC}"
echo -e "Puedes cancelar con Ctrl+C"
sleep 10
#shutdown -r now