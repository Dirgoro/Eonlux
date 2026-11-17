#!/bin/sh
# EonluxOS 1.0 Core - Configuracao inicial de sessao grafica (POSIX sh)

[ -z "$DISPLAY" ] && exit 0

WALLPAPER="/usr/share/backgrounds/eonluxos/eonlux-wallpaper.jpg"
STAMP_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/eonluxos"
STAMP_FILE="$STAMP_DIR/.defaults-applied"

mkdir -p "$STAMP_DIR"

# 1. Ajuste automatico de resolucao via EDID (suporta de 1024x600 ate Full HD+)
if command -v xrandr >/dev/null 2>&1; then
    xrandr --auto 2>/dev/null || true
fi

# 2. Aplicar temas, fontes e wallpaper oficiais do EonluxOS via xfconf-query
if command -v xfconf-query >/dev/null 2>&1; then
    xfconf-query -c xsettings -p /Net/ThemeName -n -t string -s "Adwaita-dark" 2>/dev/null || true
    xfconf-query -c xsettings -p /Net/IconThemeName -n -t string -s "Papirus-Dark" 2>/dev/null || true
    xfconf-query -c xsettings -p /Gtk/FontName -n -t string -s "Noto Sans 9" 2>/dev/null || true
    xfconf-query -c xfwm4 -p /general/theme -n -t string -s "Default-hdpi" 2>/dev/null || true
    xfconf-query -c xfwm4 -p /general/title_font -n -t string -s "Noto Sans Bold 9" 2>/dev/null || true

    # Icones compactos na area de trabalho (30px, clique unico)
    xfconf-query -c xfce4-desktop -p /desktop-icons/icon-size -n -t uint -s 30 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p /desktop-icons/single-click -n -t bool -s true 2>/dev/null || true

    # Aplicar wallpaper proporcional em todos os monitores e workspaces detectados
    if [ -f "$WALLPAPER" ]; then
        for prop in $(xfconf-query -c xfce4-desktop -l 2>/dev/null \vert{} grep -E '/last-image$'); do
            xfconf-query -c xfce4-desktop -p "$prop" -s "$WALLPAPER" 2>/dev/null || true
        done
        for style_prop in $(xfconf-query -c xfce4-desktop -l 2>/dev/null \vert{} grep -E '/image-style$'); do
            xfconf-query -c xfce4-desktop -p "$style_prop" -s 5 2>/dev/null || true
        done
        # Fallback caso as propriedades de monitor ainda nao tenham sido criadas pelo xfdesktop
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image
