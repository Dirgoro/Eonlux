# Carrega ~/.profile caso exista
if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi

# Arranque grafico silencioso enquanto o Plymouth permanece visivel ate o XFCE carregar
if [ -z "${DISPLAY:-}" ]; then
    CURRENT_TTY="$(tty 2>/dev/null || true)"
    case "$CURRENT_TTY" in
        /dev/tty1|/dev/tty2)
            if ! systemctl is-active --quiet lightdm.service 2>/dev/null; then
                printf '\033[2J\033[H\033[?25l'
                export NO_AT_BRIDGE=1
                exec dbus-run-session -- startx "$HOME/.xinitrc" -- vt7 -keeptty > "$HOME/.startx.log" 2>&1
            fi
            ;;
    esac
fi
