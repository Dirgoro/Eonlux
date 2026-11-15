# Adiciona /sbin e /usr/sbin ao PATH do utilizador para utilitários de diagnóstico (zramctl, sysctl, etc.)
case ":$PATH:" in
    *:/usr/sbin:*) ;;
    *) PATH="$PATH:/usr/local/sbin:/usr/sbin:/sbin" ;;
esac
export PATH
