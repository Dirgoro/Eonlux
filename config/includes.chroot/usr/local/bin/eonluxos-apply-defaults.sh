#!/bin/sh

WALLPAPER="/usr/share/backgrounds/eonluxos/eonlux-wallpaper.jpg"

xrandr --auto 2>/dev/null || true

xfconf-query -c xsettings -p /Net/ThemeName -n -t string -s "Adwaita-dark" 2>/dev/null || true
xfconf-query -c xsettings -p /Net/IconThemeName -n -t string -s "Papirus-Dark" 2>/dev/null || true
xfconf-query -c xsettings -p /Gtk/FontName -n -t string -s "Noto Sans 10" 2>/dev/null || true

xfconf-query -c xfce4-desktop -p /desktop-icons/icon-size -n -t uint -s 30 2>/dev/null || true
xfconf-query -c xfce4-desktop -p /desktop-icons/use-custom-font-size -n -t bool -s true 2>/dev/null || true
xfconf-query -c xfce4-desktop -p /desktop-icons/font-size -n -t double -s 8 2>/dev/null || true
xfconf-query -c xfce4-desktop -p /desktop-icons/single-click -n -t bool -s true 2>/dev/null || true

MONITORS=$(xrandr --listmonitors 2>/dev/null | awk 'NR>1 {print $4}')
[ -z "$MONITORS" ] && MONITORS="0 Virtual-1 LVDS-1 eDP-1 VGA-1 HDMI-1"

for mon in $MONITORS 0 Virtual-1 LVDS-1; do
    BASE="/backdrop/screen0/monitor${mon}/workspace0"
    xfconf-query -c xfce4-desktop -p "${BASE}/color-style" -n -t int -s 0 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p "${BASE}/image-style" -n -t int -s 2 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p "${BASE}/last-image" -n -t string -s "$WALLPAPER" 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p "${BASE}/image-path" -n -t string -s "$WALLPAPER" 2>/dev/null || true
done

# Configuração da Dock Plank alinhada com o estilo da imagem de referência
gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ hide-mode 'none' 2>/dev/null || true
gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ position 'bottom' 2>/dev/null || true
gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ alignment 'center' 2>/dev/null || true
gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ theme 'EonluxOS' 2>/dev/null || true
gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ icon-size 36 2>/dev/null || true
gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ item-size 42 2>/dev/null || true
pgrep -x plank >/dev/null || nohup plank >/dev/null 2>&1 &

xfce4-panel -r 2>/dev/null || true

for i in 1 2 3 4 5 6 7 8 9 10; do
    if pgrep -x xfdesktop >/dev/null && pgrep -x plank >/dev/null; then
        break
    fi
    sleep 0.5
done

xfdesktop --reload 2>/dev/null || true
sleep 1.2

sudo -n /usr/local/bin/eonluxos-finish-boot.sh 2>/dev/null || true
