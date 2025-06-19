#!/bin/bash
# Configuración de usuarios

print_step "Configurando usuarios"

# Configurar hostname
echo "$HOSTNAME" > /etc/hostname
echo -e "${BLUE}Hostname configurado como: $HOSTNAME${NC}"

# Configurar zona horaria
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc
echo -e "${BLUE}Zona horaria configurada como: $TIMEZONE${NC}"

# Configurar locale
sed -i "s/#$LANG/$LANG/" /etc/locale.gen
locale-gen

# Configurar todas las variables LC
cat > /etc/locale.conf << LOCALE_CONF
LANG=$LANG
LC_ADDRESS=$LANG
LC_IDENTIFICATION=$LANG
LC_MEASUREMENT=$LANG
LC_MONETARY=$LANG
LC_NAME=$LANG
LC_NUMERIC=$LANG
LC_PAPER=$LANG
LC_TELEPHONE=$LANG
LC_TIME=$LANG
LOCALE_CONF
echo -e "${BLUE}Idioma configurado como: $LANG${NC}"

# Configurar teclado
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf
echo -e "${BLUE}Mapa de teclado configurado como: $KEYMAP${NC}"

# Configurar hosts
cat > /etc/hosts << HOSTS_EOF
127.0.0.1    localhost
::1          localhost
127.0.0.1    $HOSTNAME.localdomain $HOSTNAME
HOSTS_EOF