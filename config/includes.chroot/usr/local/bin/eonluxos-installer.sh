#!/bin/sh
# EonluxOS 1.0 Core - Lancador do Instalador a partir da sessao Live

if command -v calamares >/dev/null 2>&1; then
    if command -v pkexec >/dev/null 2>&1; then
        exec pkexec calamares
    else
        exec sudo calamares
    fi
fi

if command -v debian-installer-launcher >/dev/null 2>&1; then
    if command -v pkexec >/dev/null 2>&1; then
        exec pkexec debian-installer-launcher
    else
        exec sudo debian-installer-launcher
    fi
fi

if command -v xfce4-terminal >/dev/null 2>&1; then
    exec xfce4-terminal --title="Instalar Eonlux Core" -e "sh -c 'echo \"Para instalar o EonluxOS 1.0 Core no disco, reinicie e selecione: Instalar EonluxOS 1.0 Core (Instalador Grafico) no menu de boot.\"; read -p \"Pressione Enter para fechar...\" _'"
fi
