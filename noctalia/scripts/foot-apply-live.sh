#!/usr/bin/env bash
#
# Aplica o tema do Noctalia nas janelas do foot JA ABERTAS (via OSC) e deixa o
# payload pronto em cache para as janelas NOVAS (lido pelo snippet em
# ~/.config/fish/conf.d/noctalia-foot-theme.fish).
#
# Por que isso e necessario:
#   - O foot nao tem reload de config em runtime. SIGUSR1/SIGUSR2 apenas alternam
#     entre [colors-dark] / [colors-light] que ja estao em memoria; nao releem o
#     foot.ini. (Ver "Signals" em `man foot`.)
#   - Em modo servidor (spawn-at-startup "foot" "--server" no niri), o servidor
#     parseia o foot.ini uma vez no boot e todo footclient herda aquilo. Reiniciar
#     o servidor resolveria, mas ele e dono de todas as janelas -- fecharia tudo.
#   - O hook do proprio Noctalia (Scripts/bash/template-apply.sh, caso `foot)`) so
#     garante a linha `include=` no foot.ini; nao sinaliza nada, ao contrario dos
#     casos `kitty)` e `ghostty)`.
#
# O foot documenta suporte a OSC 4 (paleta), 10/11 (fg/bg), 12 (cursor) e
# 17/19 (seleção) -- ver /usr/share/doc/foot/README.md.
#
# Disparado pelo post_hook de [templates.foot-live] em
# ~/.config/noctalia/user-templates.toml

set -uo pipefail

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/noctalia"
palette="$cache_dir/foot-live.conf"
payload_file="$cache_dir/foot-live.osc"

[ -r "$palette" ] || exit 0

declare -A color=()
while IFS='=' read -r key value; do
	[[ -n "$key" && "$key" != \#* && -n "$value" ]] || continue
	color["$key"]="$value"
done <"$palette"

esc=$'\e'
st=$'\e\\'

# OSC 4 aceita varios pares "indice;cor" numa unica sequencia.
osc4=""
for i in {0..15}; do
	[ -n "${color[$i]:-}" ] && osc4+=";$i;${color[$i]}"
done

payload=""
[ -n "$osc4" ] && payload+="${esc}]4${osc4}${st}"
[ -n "${color[fg]:-}" ] && payload+="${esc}]10;${color[fg]}${st}"
[ -n "${color[bg]:-}" ] && payload+="${esc}]11;${color[bg]}${st}"
[ -n "${color[cursor]:-}" ] && payload+="${esc}]12;${color[cursor]}${st}"
[ -n "${color[selbg]:-}" ] && payload+="${esc}]17;${color[selbg]}${st}"
[ -n "${color[selfg]:-}" ] && payload+="${esc}]19;${color[selfg]}${st}"

[ -n "$payload" ] || exit 0

mkdir -p "$cache_dir"
printf '%s' "$payload" >"$payload_file"

[ "${1:-}" = "--no-apply" ] && exit 0

# Descobre os ptys das janelas do foot: todo processo cuja arvore de pais passe por
# um processo foot/footclient. Nao escrevemos em /dev/pts/* as cegas para nao jogar
# OSC em ptys de outros terminais, tmux ou sessoes ssh.
mapfile -t ttys < <(ps -eo pid=,ppid=,comm=,tty= | awk '
	{ pid[$1] = $1; parent[$1] = $2; name[$1] = $3; term[$1] = $4 }
	END {
		for (p in pid)
			if (name[p] ~ /^foot/) isfoot[p] = 1
		for (p in pid) {
			if (term[p] == "?" || term[p] == "") continue
			q = p
			for (depth = 0; depth < 64 && (q in parent); depth++) {
				if (q in isfoot) { print "/dev/" term[p]; break }
				q = parent[q]
			}
		}
	}' | sort -u)

for tty in "${ttys[@]:-}"; do
	[ -n "$tty" ] && [ -w "$tty" ] && printf '%s' "$payload" >"$tty" 2>/dev/null
done

exit 0
