#!/usr/bin/env bash
# Mostra uma notificação quando o layout de teclado do niri muda
# (Mod+Space ou qualquer outra troca). Iniciado pelo spawn-at-startup do niri.

names=()
notif_id=0

niri msg --json event-stream \
    | grep --line-buffered '"KeyboardLayout' \
    | while IFS= read -r line; do
        case "$line" in
            *KeyboardLayoutsChanged*)
                # Lista de layouts (vem no início e quando a config é recarregada).
                mapfile -t names < <(jq -r '.KeyboardLayoutsChanged.keyboard_layouts.names[]' <<< "$line")
                ;;
            *KeyboardLayoutSwitched*)
                idx=$(jq -r '.KeyboardLayoutSwitched.idx' <<< "$line")
                name="${names[$idx]:-layout $idx}"
                # -r substitui a notificação anterior em vez de empilhar várias.
                notif_id=$(notify-send -p -r "$notif_id" -a niri -i input-keyboard \
                    -t 1500 -h string:x-canonical-private-synchronous:keyboard-layout \
                    "Teclado" "$name")
                ;;
        esac
    done
