#!/bin/sh

# Garante que nenhuma janela ultrapasse a área útil do monitor (ex: 1024x600 no Acer D260)
while true; do
    WORKAREA=$(xprop -root _NET_WORKAREA 2>/dev/null | awk -F'= ' '{print $2}' | tr -d ' ')
    WX=$(echo "$WORKAREA" | cut -d',' -f1)
    WY=$(echo "$WORKAREA" | cut -d',' -f2)
    WW=$(echo "$WORKAREA" | cut -d',' -f3)
    WH=$(echo "$WORKAREA" | cut -d',' -f4)

    # Fallback seguro para 1024x600 descontando painel superior (32px) e dock Plank (52px)
    [ -z "$WX" ] && WX=0
    [ -z "$WY" ] && WY=32
    [ -z "$WW" ] && WW=1024
    [ -z "$WH" ] && WH=516

    if [ "$WW" -gt 0 ] && [ "$WH" -gt 0 ] && command -v wmctrl >/dev/null 2>&1; then
        wmctrl -lG 2>/dev/null | while read -r wid desktop x y w h host title; do
            # Ignora área de trabalho, painéis e dock
            case "$title" in
                "Desktop"|"xfce4-panel"|"plank"|"") continue ;;
            esac

            NEED_ADJUST=0
            NEW_X=$x
            NEW_Y=$y
            NEW_W=$w
            NEW_H=$h

            # Limita largura máxima à largura útil da tela
            if [ "$NEW_W" -gt "$WW" ]; then
                NEW_W=$WW
                NEW_X=$WX
                NEED_ADJUST=1
            fi

            # Limita altura máxima à altura útil (entre painel e dock)
            if [ "$NEW_H" -gt "$WH" ]; then
                NEW_H=$WH
                NEW_Y=$WY
                NEED_ADJUST=1
            fi

            # Impede que a janela fique cortada à direita ou abaixo da dock
            MAX_X=$((WX + WW - NEW_W))
            MAX_Y=$((WY + WH - NEW_H))

            if [ "$NEW_X" -lt "$WX" ]; then
                NEW_X=$WX
                NEED_ADJUST=1
            elif [ "$NEW_X" -gt "$MAX_X" ]; then
                NEW_X=$MAX_X
                NEED_ADJUST=1
            fi

            if [ "$NEW_Y" -lt "$WY" ]; then
                NEW_Y=$WY
                NEED_ADJUST=1
            elif [ "$NEW_Y" -gt "$MAX_Y" ]; then
                NEW_Y=$MAX_Y
                NEED_ADJUST=1
            fi

            if [ "$NEED_ADJUST" -eq 1 ]; then
                wmctrl -ir "$wid" -b remove,maximized_vert,maximized_horz 2>/dev/null || true
                wmctrl -ir "$wid" -e "0,${NEW_X},${NEW_Y},${NEW_W},${NEW_H}" 2>/dev/null || true
            fi
        done
    fi

    sleep 1
done
