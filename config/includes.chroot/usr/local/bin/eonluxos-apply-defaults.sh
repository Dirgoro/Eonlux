#!/bin/sh
# EonluxOS 1.0 Core - Configuracao sincronizada da sessao grafica (POSIX sh)

[ -z "$DISPLAY" ] && exit 0

WALLPAPER="/usr/share/backgrounds/eonluxos/eonlux-wallpaper.jpg"
STAMP_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/eonluxos"
STAMP_FILE="$STAMP_DIR/.defaults-applied"

mkdir -p "$STAMP_DIR"

# 1. Pinta fundo raiz com #060C1C e ajusta resolucao via EDID (1024x600 ate Full HD)
if command -v xsetroot >/dev/null 2>&1; then
    xsetroot -solid "#060C1C" 2>/dev/null || true
fi

if command -v xrandr >/dev/null 2>&1; then
    xrandr --auto 2>/dev/null || true
fi

# 2. Aplicar temas, fontes, dock centralizada e wallpaper oficiais do EonluxOS
if command -v xfconf-query >/dev/null 2>&1; then
    xfconf-query -c xsettings -p /Net/ThemeName -n -t string -s "Adwaita-dark" 2>/dev/null || true
    xfconf-query -c xsettings -p /Net/IconThemeName -n -t string -s "Papirus-Dark" 2>/dev/null || true
    xfconf-query -c xsettings -p /Gtk/FontName -n -t string -s "Noto Sans 9" 2>/dev/null || true
    xfconf-query -c xfwm4 -p /general/theme -n -t string -s "Default-hdpi" 2>/dev/null || true
    xfconf-query -c xfwm4 -p /general/title_font -n -t string -s "Noto Sans Bold 9" 2>/dev/null || true

    # Centralizar dock inferior (panel-2) conforme a largura real do monitor
    if command -v xrandr >/dev/null 2>&1; then
        RES=$(xrandr --current 2>/dev/null | awk '/\*/ {print $1; exit}')
        SCR_W=$(echo "$RES" | cut -d'x' -f1)
        SCR_H=$(echo "$RES" | cut -d'x' -f2)
        if [ -n "$SCR_W" ] && [ -n "$SCR_H" ]; then
            DOCK_X=$(( SCR_W / 2 ))
            DOCK_Y=$(( SCR_H - 6 ))
            xfconf-query -c xfce4-panel -p /panels/panel-2/position -n -t string -s "p=10;x=${DOCK_X};y=${DOCK_Y}" 2>/dev/null || true
        fi
    fi

    # Icones compactos na area de trabalho (30px, clique unico)
    xfconf-query -c xfce4-desktop -p /desktop-icons/icon-size -n -t uint -s 30 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p /desktop-icons/single-click -n -t bool -s true 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -n -t bool -s false 2>/dev/null || true

    # Aplicar wallpaper proporcional em todos os monitores e workspaces detectados
    if [ -f "$WALLPAPER" ]; then
        for prop in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -E '/last-image$'); do
            xfconf-query -c xfce4-desktop -p "$prop" -s "$WALLPAPER" 2>/dev/null || true
        done
        for style_prop in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -E '/image-style$'); do
            xfconf-query -c xfce4-desktop -p "$style_prop" -s 5 2>/dev/null || true
        done
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -n -t string -s "$WALLPAPER" 2>/dev/null || true
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/image-style -n -t int -s 5 2>/dev/null || true
    fi
fi

# 3. Aguardar bandeja do sistema (systray) do painel superior antes de iniciar applets
sleep 1
if command -v nm-applet >/dev/null 2>&1; then
    pgrep -x nm-applet >/dev/null 2>&1 || nm-applet >/dev/null 2>&1 &
fi

if command -v blueman-applet >/dev/null 2>&1; then
    pgrep -x blueman-applet >/dev/null 2>&1 || blueman-applet >/dev/null 2>&1 &
fi

# 4. Iniciar daemon de ajuste automatico de janelas para telas 1024x600
if [ -x /usr/local/bin/eonluxos-window-fit.sh ]; then
    pgrep -f eonluxos-window-fit.sh >/dev/null 2>&1 || /usr/local/bin/eonluxos-window-fit.sh >/dev/null 2>&1 &
fi

touch "$STAMP_FILE"
exit 0
