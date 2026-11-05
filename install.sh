#!/usr/bin/env bash
# Instala as configs deste repositório nos lugares certos do sistema.
#
#   ./install.sh        instala
#   ./install.sh -n     só mostra o que faria (dry-run)
#
# Mapeamento:
#   noctalia-state/*  -> ~/.local/state/noctalia/*   (ajustes feitos pela GUI do Noctalia v5)
#   todo o resto      -> ~/.config/<mesmo caminho>
#
# Também configura o layout de teclado da máquina (via localectl), conforme a
# tabela KEYBOARD abaixo. O niri lê esse layout do sistema.
#
# Só copia arquivos versionados (git ls-files). Arquivos que já existem e são
# diferentes vão para um backup em ~/.config-backup/<data>/ antes de serem
# sobrescritos. Arquivos que existem só no sistema (temas gerados etc.) não são
# apagados.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}"
BACKUP="$HOME/.config-backup/$(date +%Y%m%d-%H%M%S)"

DRY=0
[[ "${1:-}" == "-n" || "${1:-}" == "--dry-run" ]] && DRY=1

# Layout de teclado por máquina (hostname).
# Formato: "layout|modelo|variante|opções" (campo vazio = sem valor).
#   lv3:switch = Ctrl direito funciona como AltGr (o Aula F75 não tem AltGr).
declare -A KEYBOARD=(
    [b550]="us|pc105|intl|lv3:switch"   # desktop, Aula F75 (americano)
    [thinkpad]="br|abnt2||"             # notebook, ThinkPad T14 Gen 2 (ABNT2)
)

# Arquivos do repositório que não são config.
SKIP=(README.md .gitignore install.sh)

# Se o Noctalia estiver rodando, ele pode regravar o arquivo de estado por cima
# da cópia. Nesse caso o arquivo de estado é pulado.
NOCTALIA_RUNNING=0
pgrep -x noctalia >/dev/null 2>&1 && NOCTALIA_RUNNING=1

installed=0 unchanged=0 skipped_state=0

while IFS= read -r rel; do
    for s in "${SKIP[@]}"; do [[ "$rel" == "$s" ]] && continue 2; done

    src="$REPO/$rel"
    case "$rel" in
        noctalia-state/*)
            dst="$STATE/noctalia/${rel#noctalia-state/}"
            if (( NOCTALIA_RUNNING )); then
                echo "PULADO  $dst (Noctalia está rodando)"
                skipped_state=1
                continue
            fi
            ;;
        *)
            dst="$CONFIG/$rel"
            ;;
    esac

    if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
        unchanged=$((unchanged + 1))
        continue
    fi

    if (( DRY )); then
        [[ -e "$dst" ]] && echo "ALTERAR $dst" || echo "CRIAR   $dst"
        installed=$((installed + 1))
        continue
    fi

    if [[ -e "$dst" || -L "$dst" ]]; then
        bak="$BACKUP/${dst#"$HOME"/}"
        mkdir -p "$(dirname "$bak")"
        cp -a "$dst" "$bak"
        echo "ALTERAR $dst"
    else
        echo "CRIAR   $dst"
    fi

    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    [[ -x "$src" ]] && chmod +x "$dst"
    installed=$((installed + 1))
done < <(git -C "$REPO" ls-files)

echo
if (( DRY )); then
    echo "Dry-run: $installed arquivo(s) seriam instalados, $unchanged já iguais."
else
    echo "$installed arquivo(s) instalados, $unchanged já iguais."
    [[ -d "$BACKUP" ]] && echo "Backup dos arquivos substituídos: $BACKUP"
fi

if (( skipped_state )); then
    echo
    echo "O estado do Noctalia não foi instalado porque ele está rodando. Rode:"
    echo "  pkill -x noctalia && ./install.sh && noctalia --daemon"
fi

# --- Layout de teclado --------------------------------------------------------
host="$(hostnamectl hostname 2>/dev/null || hostname)"
echo
if [[ -z "${KEYBOARD[$host]+x}" ]]; then
    echo "Teclado: hostname '$host' não está na tabela KEYBOARD; layout não alterado."
else
    IFS='|' read -r kb_layout kb_model kb_variant kb_options <<< "${KEYBOARD[$host]}"
    current() { localectl status | sed -n "s/^ *X11 $1: //p"; }
    if [[ "$(current Layout)"  == "$kb_layout"  && "$(current Model)"   == "$kb_model" &&
          "$(current Variant)" == "$kb_variant" && "$(current Options)" == "$kb_options" ]]; then
        echo "Teclado: já configurado para '$host' ($kb_layout $kb_variant)."
    elif (( DRY )); then
        echo "Teclado: rodaria: sudo localectl set-x11-keymap $kb_layout $kb_model '$kb_variant' '$kb_options'"
    else
        echo "Teclado: configurando para '$host' ($kb_layout $kb_variant), pode pedir a senha do sudo..."
        sudo localectl set-x11-keymap "$kb_layout" "$kb_model" "$kb_variant" "$kb_options"
    fi
fi
