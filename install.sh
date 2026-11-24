#!/usr/bin/env bash
# Instala as configs deste repositório nos lugares certos do sistema.
#
#   ./install.sh        instala
#   ./install.sh -n     só mostra o que faria (dry-run)
#
# Mapeamento:
#   noctalia-state/*  -> ~/.local/state/noctalia/*   (ajustes feitos pela GUI do Noctalia v5)
#   system/*          -> /*  (arquivos de sistema, instalados com sudo)
#   claude/*          -> ~/.claude/*   (Claude Code)
#   todo o resto      -> ~/.config/<mesmo caminho>
#
# O claude/settings.json é exceção: tem só as preferências escritas à mão e é
# MESCLADO no ~/.claude/settings.json (com jq), não copiado por cima. Assim
# ficam preservados os hooks que outras ferramentas instalam nele (herdr) e as
# chaves que o próprio Claude Code grava. Nas chaves versionadas, vale o repo.
#
# Também configura o layout de teclado da máquina (via localectl), conforme a
# tabela KEYBOARD abaixo. O niri lê esse layout do sistema.
#
# Se o herdr estiver instalado, recria o que ele gera e por isso não é
# versionado: as completions do fish (herdr completion fish) e a integração
# com o Claude Code (herdr integration install claude).
#
# Só copia arquivos versionados (git ls-files). Arquivos que já existem e são
# diferentes vão para um backup em ~/.config-backup/<data>/ antes de serem
# sobrescritos. Arquivos que existem só no sistema (temas gerados etc.) não são
# apagados.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}"
CLAUDE_DIR="$HOME/.claude"
BACKUP="$HOME/.config-backup/$(date +%Y%m%d-%H%M%S)"

DRY=0
[[ "${1:-}" == "-n" || "${1:-}" == "--dry-run" ]] && DRY=1

# Layout de teclado por máquina (hostname).
# Formato: "layout|modelo|variante|opções" (campo vazio = sem valor).
#   lv3:switch = Ctrl direito funciona como AltGr (o Aula F75 não tem AltGr).
#   A tecla /? do T14 ABNT2 envia o código do Ctrl direito; quem a corrige é a
#   regra system/etc/udev/hwdb.d/90-thinkpad-t14-abnt2.hwdb (só no teclado
#   interno), por isso não dá para usar a variante br(thinkpad) junto com
#   lv3:switch.
declare -A KEYBOARD=(
    [b550]="us|pc105|intl|lv3:switch"   # desktop, Aula F75 (americano)
    [thinkpad]="br,us|abnt2|,intl|lv3:switch"  # notebook, ThinkPad T14 Gen 2 (ABNT2) + Aula F75 externo (Mod+Space alterna)
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
        system/*)
            continue   # instalados na seção "Arquivos de sistema" abaixo
            ;;
        claude/settings.json)
            continue   # mesclado na seção "Claude Code" abaixo
            ;;
        claude/*)
            dst="$CLAUDE_DIR/${rel#claude/}"
            ;;
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

# --- Arquivos de sistema (system/* -> /*) -------------------------------------
echo
sys_changed=0 hwdb_changed=0
while IFS= read -r rel; do
    src="$REPO/$rel"
    dst="/${rel#system/}"
    [[ -f "$dst" ]] && cmp -s "$src" "$dst" && continue
    sys_changed=$((sys_changed + 1))
    [[ "$dst" == /etc/udev/hwdb.d/* ]] && hwdb_changed=1
    if (( DRY )); then
        [[ -e "$dst" ]] && echo "ALTERAR $dst (sudo)" || echo "CRIAR   $dst (sudo)"
        continue
    fi
    if [[ -e "$dst" ]]; then
        bak="$BACKUP/system$dst"
        mkdir -p "$(dirname "$bak")"
        sudo cp -a "$dst" "$bak"
        echo "ALTERAR $dst"
    else
        echo "CRIAR   $dst"
    fi
    sudo install -D -m 644 "$src" "$dst"
done < <(git -C "$REPO" ls-files system/)

if (( sys_changed == 0 )); then
    echo "Sistema: arquivos já iguais."
elif (( hwdb_changed && ! DRY )); then
    echo "Sistema: recarregando regras de teclado (hwdb)..."
    sudo systemd-hwdb update
    sudo udevadm trigger --subsystem-match=input --action=change
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

# --- Claude Code: preferências (claude/settings.json -> ~/.claude/settings.json)
# Mescla em vez de copiar; veja o comentário no topo.
echo
cl_src="$REPO/claude/settings.json"
cl_dst="$CLAUDE_DIR/settings.json"
if ! command -v jq >/dev/null 2>&1; then
    echo "Claude: jq não instalado; preferências não aplicadas."
else
    tmp="$(mktemp)"
    if [[ -f "$cl_dst" ]]; then
        jq -s '.[0] * .[1]' "$cl_dst" "$cl_src" > "$tmp"
    else
        jq . "$cl_src" > "$tmp"
    fi
    if [[ -f "$cl_dst" ]] && jq -e -n --slurpfile a "$cl_dst" --slurpfile b "$tmp" '$a == $b' >/dev/null; then
        echo "Claude: preferências já aplicadas em $cl_dst."
    elif (( DRY )); then
        if [[ -f "$cl_dst" ]]; then
            echo "ALTERAR $cl_dst (mescla das preferências; chaves que mudariam:)"
            jq -r -n --slurpfile a "$cl_dst" --slurpfile b "$tmp" \
                '$b[0] | keys[] as $k | select($a[0][$k] != .[$k]) | "          \($k)"'
        else
            echo "CRIAR   $cl_dst"
        fi
    else
        if [[ -f "$cl_dst" ]]; then
            bak="$BACKUP/${cl_dst#"$HOME"/}"
            mkdir -p "$(dirname "$bak")"
            cp -a "$cl_dst" "$bak"
            echo "ALTERAR $cl_dst (preferências mescladas)"
        else
            echo "CRIAR   $cl_dst"
        fi
        mkdir -p "$(dirname "$cl_dst")"
        cat "$tmp" > "$cl_dst"
    fi
    rm -f "$tmp"
fi

# --- herdr: arquivos gerados --------------------------------------------------
# Não ficam no repositório porque o próprio herdr os gera; são recriados aqui.
echo
if ! command -v herdr >/dev/null 2>&1; then
    echo "herdr: não instalado; completions e integração com o Claude puladas."
else
    comp="$CONFIG/fish/completions/herdr.fish"
    tmp="$(mktemp)"
    herdr completion fish > "$tmp"
    if [[ -f "$comp" ]] && cmp -s "$tmp" "$comp"; then
        echo "herdr: completions do fish já iguais."
    elif (( DRY )); then
        [[ -e "$comp" ]] && echo "ALTERAR $comp (herdr completion fish)" \
                         || echo "CRIAR   $comp (herdr completion fish)"
    else
        [[ -e "$comp" ]] && echo "ALTERAR $comp" || echo "CRIAR   $comp"
        mkdir -p "$(dirname "$comp")"
        cp "$tmp" "$comp"
    fi
    rm -f "$tmp"

    # Rodar o install de novo é seguro (não duplica hooks no settings.json), mas
    # consultar o status evita regravar o hook à toa e deixa o dry-run dizer o
    # que faria. O install falha se ~/.claude não existir; na prática ele já foi
    # criado acima (statusline e preferências), mas a checagem fica por segurança.
    claude_status="$(herdr integration status 2>/dev/null | sed -n 's/^claude: //p')"
    claude_status="${claude_status%% (/*}"   # tira o caminho: "current (v11)"
    if [[ "$claude_status" == current* ]]; then
        echo "herdr: integração com o Claude já instalada ($claude_status)."
    elif (( DRY )); then
        echo "herdr: rodaria: herdr integration install claude (status: ${claude_status:-desconhecido})"
    elif [[ ! -d "$CLAUDE_DIR" ]]; then
        echo "herdr: ~/.claude não existe; abra o Claude Code uma vez e rode ./install.sh de novo."
    else
        echo "herdr: instalando integração com o Claude (status: ${claude_status:-desconhecido})..."
        herdr integration install claude
    fi
fi
