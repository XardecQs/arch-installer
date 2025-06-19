#!/bin/bash
# Finalización

print_step "Finalizando instalación"

# Configurar usuario root
echo ""
echo -e "${YELLOW}CONFIGURANDO USUARIO ROOT${NC}"
echo "Ingresa la nueva contraseña para root:"
passwd

# Crear usuario principal
echo ""
echo -e "${YELLOW}CREANDO USUARIO PRINCIPAL${NC}"
read -rp "Nombre de usuario: " USERNAME
useradd -m -G wheel -s /bin/zsh "$USERNAME"
echo "Ingresa la contraseña para $USERNAME:"
passwd "$USERNAME"

# Configurar sudo
echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/wheel

# Mensaje de bienvenida
cat > /etc/issue << WELCOME_EOF

Bienvenido a tu sistema Arch Linux!

WELCOME_EOF

# Limpiar instalador
rm -rf /arch-installer
rm /arch-chroot.sh