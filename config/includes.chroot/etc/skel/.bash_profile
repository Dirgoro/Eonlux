# Carrega ~/.profile caso exista
if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi

# Arranque grafico silencioso e imediato com sessao D-Bus ativa
if [ -z "${DISPLAY:-}" ]; then
    CURRENT_TTY="$(tty 2>/dev/null || true)"
    case "$CURRENT_TTY" in
        /dev/tty1|/dev/tty2)
            if ! systemctl is-active --quiet lightdm.service 2>/dev/null; then
                # Limpa o ecra com a cor de fundo antes de libertar o Plymouth
                printf '\033[2J\033[H\033[?25l'
                if command -v plymouth >/dev/null 2>&1; then
                    plymouth quit 2>/dev/null || true
                fi

                VT_NUM="${CURRENT_TTY#/dev/tty}"
                export NO_AT_BRIDGE=1
                exec dbus-run-session -- startx "$HOME/.xinitrc" -- "vt${VT_NUM}" -keeptty > "$HOME/.startx.log" 2>&1
            fi
            ;;
    esac
fi
