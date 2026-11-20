#!/bin/sh
# EonluxOS 1.0 Core - Inicializacao instantanea e limpa da sessao grafica (POSIX sh)

[ -z "${DISPLAY:-}" ] && exit 0

WALLPAPER="/usr/share/backgrounds/eonluxos/eonlux-wallpaper.jpg"
STAMP_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/eonluxos"
STAMP_FILE="$STAMP_DIR/.defaults-applied"

mkdir -p "$STAMP_DIR"

# 1. Pinta imediatamente a raiz do Xorg em #060C1C
if command -v xsetroot >/dev/null 2>&1; then
    xsetroot -solid "#060C1C" 2>/dev/null || true
fi

# 2. Ajuste automatico de resolucao via EDID (suporta 1024x600 ate Full HD+)
if command -v xrandr >/dev/null 2>&1; then
    xrandr --auto 2>/dev/null || true
fi

# 3. Aplica temas, fontes, dock inferior e wallpaper sem reiniciar o painel
if command -v xfconf-query >/dev/null 2>&1; then
    xfconf-query -c xsettings -p /Net/ThemeName -n -t string -s "Adwaita-dark" 2>/dev/null || true
    xfconf-query -c xsettings -p /Net/IconThemeName -n -t string -s "Papirus-Dark" 2>/dev/null || true
    xfconf-query -c xsettings -p /Gtk/FontName -n -t string -s "Noto Sans 9" 2>/dev/null || true
    xfconf-query -c xfwm4 -p /general/theme -n -t string -s "Default-hdpi" 2>/dev/null || true
    xfconf-query -c xfwm4 -p /general/title_font -n -t string -s "Noto Sans Bold 9" 2>/dev/null || true

    # Icones compactos do desktop (30px, clique unico, sem Sistema de ficheiros)
    xfconf-query -c xfce4-desktop -p /desktop-icons/icon-size -n -t uint -s 30 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p /desktop-icons/single-click -n -t bool -s true 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-home -n -t bool -s true 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -n -t bool -s false 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-trash -n -t bool -s true 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-removable -n -t bool -s true 2>/dev/null || true

    # Centraliza dinamicamente a dock inferior (panel-2) na largura real do monitor
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

    # Aplica wallpaper proporcional em todos os monitores e workspaces
    if [ -f "$WALLPAPER" ]; then
        if command -v xrandr >/dev/null 2>&1; then
            for out in $(xrandr --query 2>/dev/null | awk '/ connected/ {print $1}'); do
                for ws in 0 1 2 3; do
                    xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitor${out}/workspace${ws}/last-image" -n -t string -s "$WALLPAPER" 2>/dev/null || true
                    xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitor${out}/workspace${ws}/image-style" -n -t int -s 5 2>/dev/null || true
                done
            done
        fi
        for prop in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -E '/last-image$|/image-path$'); do
            xfconf-query -c xfce4-desktop -p "$prop" -s "$WALLPAPER" 2>/dev/null || true
        done
    fi
fi

# 4. Mantem o icone "Instalar Eonlux Core" apenas no modo Live e oculta apos instalacao em disco
DESKTOP_DIR="${XDG_DESKTOP_DIR:-$HOME/Desktop}"
[ -d "$HOME/Área de trabalho" ] && DESKTOP_DIR="$HOME/Área de trabalho"
if [ -d /run/live/medium ]; then
    if [ -f /etc/skel/Desktop/install-eonluxos.desktop ] && [ ! -f "$DESKTOP_DIR/install-eonluxos.desktop" ]; then
        mkdir -p "$DESKTOP_DIR"
        cp -f /etc/skel/Desktop/install-eonluxos.desktop "$DESKTOP_DIR/install-eonluxos.desktop"
        chmod 0755 "$DESKTOP_DIR/install-eonluxos.desktop"
    fi
else
    rm -f "$HOME/Desktop/install-eonluxos.desktop" "$HOME/Área de trabalho/install-eonluxos.desktop" 2>/dev/null || true
fi

# 5. Evita duplicacao dos applets de rede e Bluetooth (ja geridos pelo /etc/xdg/autostart)
if [ ! -f /etc/xdg/autostart/nm-applet.desktop ] && command -v nm-applet >/dev/null 2>&1; then
    pgrep -f "nm-applet" >/dev/null 2>&1 || nm-applet >/dev/null 2>&1 &
fi

if [ ! -f /etc/xdg/autostart/blueman.desktop ] && command -v blueman-applet >/dev/null 2>&1; then
    pgrep -f "blueman-applet" >/dev/null 2>&1 || blueman-applet >/dev/null 2>&1 &
fi

# 6. Inicia daemon de ajuste automatico de janelas para telas 1024x600
if [ -x /usr/local/bin/eonluxos-window-fit.sh ]; then
    pgrep -f eonluxos-window-fit.sh >/dev/null 2>&1 || /usr/local/bin/eonluxos-window-fit.sh >/dev/null 2>&1 &
fi

# 7. Atualiza o desktop e encerra o Plymouth imediatamente sem atrasos fixos
xfdesktop --reload >/dev/null 2>&1 || true

if command -v plymouth >/dev/null 2>&1; then
    plymouth quit --retain-splash 2>/dev/null || plymouth quit 2>/dev/null || true
fi

touch "$STAMP_FILE"
exit 0
