#!/bin/sh
# EonluxOS 1.0 Core - Ajuste automatico de janelas para telas 1024x600 (POSIX sh)

[ -z "${DISPLAY:-}" ] && exit 0
command -v wmctrl >/dev/null 2>&1 || exit 0
command -v xprop >/dev/null 2>&1 || exit 0

sleep 2

while true; do
    WORKAREA=$(xprop -root _NET_WORKAREA 2>/dev/null | awk -F'= ' '{print $2}' | cut -d',' -f1-4 | tr -d ' ')
    if [ -n "$WORKAREA" ]; then
        WA_X=$(echo "$WORKAREA" | cut -d',' -f1)
        WA_Y=$(echo "$WORKAREA" | cut -d',' -f2)
        WA_W=$(echo "$WORKAREA" | cut -d',' -f3)
        WA_H=$(echo "$WORKAREA" | cut -d',' -f4)

        case "$WA_W" in
            ''|*[!0-9]*) WA_W=1024 ;;
        esac
        case "$WA_H" in
            ''|*[!0-9]*) WA_H=568 ;;
        esac

        if [ "$WA_W" -gt 200 ] && [ "$WA_H" -gt 200 ]; then
            wmctrl -lG 2>/dev/null | while IFS= read -r line; do
                WIN_ID=$(echo "$line" | awk '{print $1}')
                DESK=$(echo "$line" | awk '{print $2}')
                WX=$(echo "$line" | awk '{print $3}')
                WY=$(echo "$line" | awk '{print $4}')
                WW=$(echo "$line" | awk '{print $5}')
                WH=$(echo "$line" | awk '{print $6}')
                TITLE=$(echo "$line" | cut -d' ' -f8-)

                # Ignora janelas desktop, paineis e dialogos compactos
                [ "$DESK" = "-1" ] && continue
                case "$TITLE" in
                    *xfce4-panel*|*Desktop*|*"Área de trabalho"*) continue ;;
                esac
                [ "$WW" -le 520 ] && [ "$WH" -le 300 ] && continue

                NEW_W="$WW"
                NEW_H="$WH"
                NEW_X="$WX"
                NEW_Y="$WY"
                CHANGED=0

                if [ "$WW" -gt "$WA_W" ]; then
                    NEW_W="$WA_W"
                    CHANGED=1
                fi

                MAX_H=$(( WA_H - 28 ))
                if [ "$WH" -gt "$MAX_H" ]; then
                    NEW_H="$MAX_H"
                    CHANGED=1
                fi

                if [ "$NEW_X" -lt "$WA_X" ] || [ $(( NEW_X + NEW_W )) -gt $(( WA_X + WA_W )) ]; then
                    NEW_X="$WA_X"
                    CHANGED=1
                fi

                if [ "$NEW_Y" -lt "$WA_Y" ] || [ $(( NEW_Y + NEW_H + 28 )) -gt $(( WA_Y + WA_H )) ]; then
                    NEW_Y="$WA_Y"
                    CHANGED=1
                fi

                if [ "$CHANGED" -eq 1 ]; then
                    wmctrl -i -r "$WIN_ID" -b remove,maximized_vert,maximized_horz 2>/dev/null || true
                    wmctrl -i -r "$WIN_ID" -e "0,${NEW_X},${NEW_Y},${NEW_W},${NEW_H}" 2>/dev/null || true
                fi
            done
        fi
    fi
    sleep 2
done
