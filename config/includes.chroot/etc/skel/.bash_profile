# Carrega ~/.profile caso exista
if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi

# Fallback seguro: se o LightDM nao assumir a sessao grafica no tty1, inicia o Xorg automaticamente
if [ -z "${DISPLAY:-}" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ]; then
    if ! systemctl is-active --quiet lightdm.service 2>/dev/null; then
        exec startx
    fi
fi
