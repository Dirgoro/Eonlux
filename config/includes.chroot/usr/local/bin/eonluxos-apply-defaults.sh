#!/bin/sh
# EonluxOS 1.0 Core - Configuracao inicial de sessao grafica (POSIX sh)

[ -z "$DISPLAY" ] && exit 0

WALLPAPER="/usr/share/backgrounds/eonluxos/eonlux-wallpaper.jpg"
STAMP_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/eonluxos"
STAMP_FILE="$STAMP_DIR/.defaults-applied"

mkdir -p "$STAMP_DIR"

# 1. Pinta o fundo raiz do Xorg na cor oficial #060C1C
if command -v xsetroot >/dev/null 2>&1; then
    xsetroot -solid "#060C1C" 2>/dev/null || true
fi

# 2. Ajuste automatico de resolucao via EDID (suporta de 1024x600 ate Full HD+)
if command -v xrandr >/dev/null 2>&1; then
    xrandr --auto 2>/dev/null || true
fi

# 3. Aplicar temas, fontes, paineis e wallpaper oficiais do EonluxOS via xfconf-query
if command -v xfconf-query >/dev/null 2>&1; then
    xfconf-query -c xsettings -p /Net/ThemeName -n -t string -s "Adwaita-dark" 2>/dev/null || true
    xfconf-query -c xsettings -p /Net/IconThemeName -n -t string -s "Papirus-Dark" 2>/dev/null || true
    xfconf-query -c xsettings -p /Gtk/FontName -n -t string -s "Noto Sans 9" 2>/dev/null || true
    xfconf-query -c xfwm4 -p /general/theme -n -t string -s "Default-hdpi" 2>/dev/null || true
    xfconf-query -c xfwm4 -p /general/title_font -n -t string -s "Noto Sans Bold 9" 2>/dev/null || true

    # Garantir painel superior (1) e dock inferior (2) ativos
    xfconf-query -c xfce4-panel -p /panels -n -t int -t int -s 1 -s 2 2>/dev/null || true

    # Icones compactos na area de trabalho (30px, clique unico, sem icone Sistema de ficheiros)
    xfconf-query -c xfce4-desktop -p /desktop-icons/icon-size -n -t uint -s 30 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p /desktop-icons/single-click -n -t bool -s true 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-home -n -t bool -s true 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -n -t bool -s false 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-trash -n -t bool -s true 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-removable -n -t bool -s true 2>/dev/null || true

    # Aplicar wallpaper proporcional em todos os monitores e workspaces detectados
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
        xfdesktop --reload >/dev/null 2>&1 || true
    fi
fi

# 4. Iniciar applets leves de rede e Bluetooth (se instalados)
if command -v nm-applet >/dev/null 2>&1; then
    pgrep -x nm-applet >/dev/null 2>&1 || nm-applet >/dev/null 2>&1 &
fi

if command -v blueman-applet >/dev/null 2>&1; then
    pgrep -x blueman-applet >/dev/null 2>&1 || blueman-applet >/dev/null 2>&1 &
fi

# 5. Iniciar Plank apenas se estiver disponivel (fallback silencioso para panel-2 no Debian Trixie)
if command -v plank >/dev/null 2>&1; then
    pgrep -x plank >/dev/null 2>&1 || plank >/dev/null 2>&1 &
fi

# 6. Iniciar daemon de ajuste automatico de janelas para telas 1024x600
if [ -x /usr/local/bin/eonluxos-window-fit.sh ]; then
    pgrep -f eonluxos-window-fit.sh >/dev/null 2>&1 || /usr/local/bin/eonluxos-window-fit.sh >/dev/null 2>&1 &
fi

# 7. Dispensar o Plymouth agora que o XFCE esta desenhado no vt7
if command -v plymouth >/dev/null 2>&1; then
    plymouth quit --retain-splash 2>/dev/null || plymouth quit 2>/dev/null || true
fi

touch "$STAMP_FILE"
exit 0
