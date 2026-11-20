# Carrega ~/.profile caso exista
if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi

# Arranque grafico silencioso e imediato com sessao D-Bus ativa
if [ -z "${DISPLAY:-}" ]; then
    case "$(tty 2>/dev/null)" in
        /dev/tty1|/dev/tty2)
            if ! systemctl is-active --quiet lightdm.service 2>/dev/null; then
                export NO_AT_BRIDGE=1
                exec dbus-run-session -- startx -- -keeptty > /dev/null 2>&1
            fi
            ;;
    esac
fi
