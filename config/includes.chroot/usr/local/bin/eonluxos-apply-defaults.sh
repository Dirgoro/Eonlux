#!/bin/sh

WALLPAPER="/usr/share/backgrounds/eonluxos/eonlux-wallpaper.jpg"

# Ajusta automaticamente cada saída de vídeo para a resolução nativa (EDID) do monitor
xrandr --auto 2>/dev/null || true

xfconf-query -c xsettings -p /Net/ThemeName -n -t string -s "Adwaita-dark" 2>/dev/null || true
xfconf-query -c xsettings -p /Net/IconThemeName -n -t string -s "Papirus-Dark" 2>/dev/null || true

xfconf-query -c xfce4-desktop -p /desktop-icons/icon-size -n -t uint -s 30 2>/dev/null || true
xfconf-query -c xfce4-desktop -p /desktop-icons/use-custom-font-size -n -t bool -s true 2>/dev/null || true
xfconf-query -c xfce4-desktop -p /desktop-icons/font-size -n -t double -s 8 2>/dev/null || true
xfconf-query -c xfce4-desktop -p /desktop-icons/single-click -n -t bool -s true 2>/dev/null || true

MONITORS=$(xrandr --listmonitors 2>/dev/null | awk 'NR>1 {print $4}')
[ -z "$MONITORS" ] && MONITORS="0 Virtual-1 LVDS-1 eDP-1 VGA-1 HDMI-1"

for mon in $MONITORS 0 Virtual-1 LVDS-1; do
    BASE="/backdrop/screen0/monitor${mon}/workspace0"
    xfconf-query -c xfce4-desktop -p "${BASE}/color-style" -n -t int -s 0 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p "${BASE}/image-style" -n -t int -s 3 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p "${BASE}/last-image" -n -t string -s "$WALLPAPER" 2>/dev/null || true
    xfconf-query -c xfce4-desktop -p "${BASE}/image-path" -n -t string -s "$WALLPAPER" 2>/dev/null || true
done

xfdesktop --reload 2>/dev/null || true

gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ hide-mode 'none' 2>/dev/null || true
gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ position 'bottom' 2>/dev/null || true
gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ alignment 'center' 2>/dev/null || true
gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ theme 'EonluxOS' 2>/dev/null || true
gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ icon-size 36 2>/dev/null || true
pgrep -x plank >/dev/null || nohup plank >/dev/null 2>&1 &

sleep 1
sudo -n /usr/local/bin/eonluxos-finish-boot.sh 2>/dev/null || true
