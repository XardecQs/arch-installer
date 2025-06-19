#!/bin/bash
# Entorno gráfico

print_step "Instalación de entorno gráfico"

echo ""
read -rp "¿Instalar entorno gráfico? (s/N): " gui
if [[ "$gui" =~ ^[Ss]$ ]]; then
    echo "1) GNOME  2) KDE  3) XFCE"
    read -rp "Opción: " desktop
    
    case $desktop in
        1) 
            print_step "Instalando GNOME"
            pacman -S --noconfirm gnome gdm
            systemctl enable gdm
            ;;
        2) 
            print_step "Instalando KDE Plasma"
            pacman -S --noconfirm plasma sddm
            systemctl enable sddm
            ;;
        3) 
            print_step "Instalando XFCE"
            pacman -S --noconfirm xfce4 lightdm lightdm-gtk-greeter
            systemctl enable lightdm
            ;;
    esac
fi