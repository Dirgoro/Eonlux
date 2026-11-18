#!/bin/sh
# EonluxOS 1.0 Core - Configuracao sincronizada da sessao grafica (POSIX sh)

[ -z "$DISPLAY" ] && exit 0

WALLPAPER="/usr/share/backgrounds/eonluxos/eonlux-wallpaper.jpg"
STAMP_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/eonluxos"
STAMP_FILE="$STAMP_DIR/.defaults-applied"

mkdir -p "$STAMP_DIR"

# 1. Pinta imediatamente a raiz do Xorg em #060C1C
if command -v xsetroot >/dev/null 2>&1; then
    xsetroot -solid "#060C1C" 2>/dev/null || true
fi

# 2. Ajuste automatico de resolucao via EDID (1024x600 ate Full HD+)
if command -v xrandr >/dev/null 2>&1; then
    xrandr --auto 2>/dev/null || true
fi

# 3. Aplicar temas, fontes, dock inferior, notificacoes e wallpaper via xfconf-query
if command -v xfconf-query >/dev/null 2>&1; then
    xfconf-query -c xsettings -p /Net/ThemeName -n -t string -s "Adwaita-dark" 2>/dev/null || true
    xfconf-query -c xsettings -p /Net/IconThemeName -n -t string -s "Papirus-Dark" 2>/dev/null || true
    xfconf-query -c xsettings -p /Gtk/FontName -n -t string -s "Noto Sans 9" 2>/dev/null || true
    xfconf-query -c xfwm4 -p /general/theme -n -t string -s "Default-hdpi" 2>/dev/null || true
    xfconf-query -c xfwm4 -p /general/title_font -n -t string -s "Noto Sans Bold 9" 2>/dev/null || true

    # Notificacoes escuras e compactas no canto superior direito
    xfconf-query -c xfce4-notifyd -p /theme -n -t string -s "Default" 2>/dev/null || true
    xfconf-query -c xfce4-notifyd -p /expire-timeout -n -t int -s 4 2>/dev/null || true

    # Icones compactos do desktop (oculta Sistema de ficheiros)
    xfconf-query -c xfce4-desktop -p /desktop-icons/icon-size -n -t uint -s 30 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p /desktop-icons/single-click -n -t bool -s true 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-home -n -t bool -s true 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -n -t bool -s false 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-trash -n -t bool -s true 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-removable -n -t bool -s true 2>/dev/null || true

    # Garantir painel superior (1) e dock inferior (2) configurados e ancorados
    xfconf-query -c xfce4-panel -p /panels -n -t int -t int -s 1 -s 2 2>/dev/null || true
    xfconf-query -c xfce4-panel -p /panels/panel-2/size -n -t uint -s 42 2>/dev/null || true
    xfconf-query -c xfce4-panel -p /panels/panel-2/icon-size -n -t uint -s 28 2>/dev/null || true
    xfconf-query -c xfce4-panel -p /panels/panel-2/length -n -t uint -s 1 2>/dev/null || true
    xfconf-query -c xfce4-panel -p /panels/panel-2/length-adjust -n -t bool -s true 2>/dev/null || true
    xfconf-query -c xfce4-panel -p /panels/panel-2/position-locked -n -t bool -s true 2>/dev/null || true
    xfconf-query -c xfce4-panel -p /panels/panel-2/autohide-behavior -n -t uint -s 0 2>/dev/null || true
    xfconf-query -c xfce4-panel -p /panels/panel-2/plugin-ids -n -t int -t int -t int -t int -t int -s 10 -s 11 -s 12 -s 13 -s 14 2>/dev/null || true

    xfconf-query -c xfce4-panel -p /plugins/plugin-10 -n -t string -s "launcher" 2>/dev/null || true
    xfconf-query -c xfce4-panel -p /plugins/plugin-10/items -n -t string -s "firefox-esr.desktop" 2>/dev/null || true
    xfconf-query -c xfce4-panel -p /plugins/plugin-11 -n -t string -s "launcher" 2>/dev/null || true
    xfconf-query -c xfce4-panel -p /plugins/plugin-11/items -n -t string -s "thunar.desktop" 2>/dev/null || true
    xfconf-query -c xfce4-panel -p /plugins/plugin-12 -n -t string -s "launcher" 2>/dev/null || true
    xfconf-query -c xfce4-panel -p /plugins/plugin-12/items -n -t string -s "xfce4-terminal.desktop" 2>/dev/null || true
    xfconf-query -c xfce4-panel -p /plugins/plugin-13 -n -t string -s "launcher" 2>/dev/null || true
    xfconf-query -c xfce4-panel -p /plugins/plugin-13/items -n -t string -s "galculator.desktop" 2>/dev/null || true
    xfconf-query -c xfce4-panel -p /plugins/plugin-14 -n -t string -s "launcher" 2>/dev/null || true
    xfconf-query -c xfce4-panel -p /plugins/plugin-14/items -n -t string -s "xfce-settings-manager.desktop" 2>/dev/null || true

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

    # Aplicar wallpaper proporcional em todos os monitores e workspaces
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

# 4. Evitar duplicacao do nm-applet (ja iniciado pelo /etc/xdg/autostart/nm-applet.desktop)
sleep 1
if command -v nm-applet >/dev/null 2>&1; then
    pgrep -f "nm-applet" >/dev/null 2>&1 || nm-applet >/dev/null 2>&1 &
fi

if command -v blueman-applet >/dev/null 2>&1; then
    pgrep -f "blueman-applet" >/dev/null 2>&1 || blueman-applet >/dev/null 2>&1 &
fi

# 5. Iniciar daemon de ajuste automatico de janelas para telas 1024x600
if [ -x /usr/local/bin/eonluxos-window-fit.sh ]; then
    pgrep -f eonluxos-window-fit.sh >/dev/null 2>&1 || /usr/local/bin/eonluxos-window-fit.sh >/dev/null 2>&1 &
fi

# 6. Recarregar painel (para exibir barra superior + dock inferior) e wallpaper antes de dispensar o Plymouth
xfce4-panel -r >/dev/null 2>&1 &
xfdesktop --reload >/dev/null 2>&1 || true
sleep 2

if command -v plymouth >/dev/null 2>&1; then
    plymouth quit --retain-splash 2>/dev/null || plymouth quit 2>/dev/null || true
fi

touch "$STAMP_FILE"
exit 0
