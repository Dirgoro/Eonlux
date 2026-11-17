#!/bin/sh
# EonluxOS 1.0 Core - Inicializacao sincronizada do ambiente grafico e wallpaper

# 1. Pinta imediatamente a janela raiz do Xorg com #060C1C antes de qualquer componente
if command -v xsetroot >/dev/null 2>&1; then
    xsetroot -solid "#060C1C" 2>/dev/null || true
fi

# 2. Ajuste automatico de resolucao via EDID (suporta 1024x600 ate Full HD)
if command -v xrandr >/dev/null 2>&1; then
    xrandr --auto 2>/dev/null || true
fi

# 3. Garante temas GTK, icones e fontes oficiais do EonluxOS
xfconf-query -c xsettings -p /Net/ThemeName -n -t string -s "Adwaita-dark" 2>/dev/null || true
xfconf-query -c xsettings -p /Net/IconThemeName -n -t string -s "Papirus-Dark" 2>/dev/null || true
xfconf-query -c xsettings -p /Gtk/FontName -n -t string -s "Noto Sans 9" 2>/dev/null || true
xfconf-query -c xfwm4 -p /general/theme -n -t string -s "Default" 2>/dev/null || true

# 4. Aplica o wallpaper oficial em TODOS os monitores detectados via xrandr e xfconf
WALLPAPER="/usr/share/backgrounds/eonluxos/eonlux-wallpaper.jpg"
if [ -f "$WALLPAPER" ]; then
    if command -v xrandr >/dev/null 2>&1; then
        for out in $(xrandr --query 2>/dev/null | awk '/ connected/ {print $1}'); do
            for ws in 0 1 2 3; do
                xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitor${out}/workspace${ws}/last-image" -n -t string -s "$WALLPAPER" 2>/dev/null || true
                xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitor${out}/workspace${ws}/image-style" -n -t int -s 5 2>/dev/null || true
            done
        done
    fi

    for prop in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -E 'last-image$|image-path$'); do
        xfconf-query -c xfce4-desktop -p "$prop" -s "$WALLPAPER" 2>/dev/null || true
    done

    xfdesktop --reload 2>/dev/null || true
fi

# 5. Garante que os applets de rede e bluetooth estejam ativos
if ! pgrep -x nm-applet >/dev/null 2>&1; then
    nm-applet >/dev/null 2>&1 &
fi

if ! pgrep -x blueman-applet >/dev/null 2>&1; then
    blueman-applet >/dev/null 2>&1 &
fi

# 6. Inicia o gestor leve de janelas para caberem 100% em 1024x600
if [ -x /usr/local/bin/eonluxos-window-fit.sh ] && ! pgrep -f eonluxos-window-fit.sh >/dev/null 2>&1; then
    /usr/local/bin/eonluxos-window-fit.sh >/dev/null 2>&1 &
fi

# 7. Aguarda painel, wallpaper e dock desenharem e so entao dispensa o Plymouth
sleep 1
if command -v plymouth >/dev/null 2>&1; then
    plymouth quit --retain-splash 2>/dev/null || plymouth quit 2>/dev/null || true
fi

exit 0
