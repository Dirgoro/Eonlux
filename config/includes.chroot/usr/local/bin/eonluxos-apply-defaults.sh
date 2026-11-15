#!/bin/sh

WALLPAPER="/usr/share/backgrounds/eonluxos/eonlux-wallpaper.jpg"

# Aguarda o daemon xfconfd estar pronto
sleep 1

xfconf-query -c xsettings -p /Net/ThemeName -n -t string -s "Adwaita-dark" 2>/dev/null || true
xfconf-query -c xsettings -p /Net/IconThemeName -n -t string -s "Papirus-Dark" 2>/dev/null || true

xfconf-query -c xfce4-desktop -p /desktop-icons/icon-size -n -t uint -s 30 2>/dev/null || true
xfconf-query -c xfce4-desktop -p /desktop-icons/use-custom-font-size -n -t bool -s true 2>/dev/null || true
xfconf-query -c xfce4-desktop -p /desktop-icons/font-size -n -t double -s 8 2>/dev/null || true
xfconf-query -c xfce4-desktop -p /desktop-icons/single-click -n -t bool -s true 2>/dev/null || true

# Detecta todos os monitores ativos (ex: Virtual-1, VGA-1, LVDS-1, eDP-1) e aplica o wallpaper sem cortes (style=4)
MONITORS=$(xrandr --listmonitors 2>/dev/null | awk 'NR>1 {print $4}')
[ -z "$MONITORS" ] && MONITORS="monitor0 Virtual-1"

for mon in $MONITORS; do
    BASE="/backdrop/screen0/monitor${mon}/workspace0"
    xfconf-query -c xfce4-desktop -p "${BASE}/image-style" -n -t int -s 4 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p "${BASE}/last-image" -n -t string -s "$WALLPAPER" 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p "${BASE}/color-style" -n -t int -s 0 2>/dev/null || true
done
