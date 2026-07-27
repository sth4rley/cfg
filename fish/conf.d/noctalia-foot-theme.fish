# Aplica o tema atual do Noctalia em janelas NOVAS do foot.
#
# Com `foot --server` (spawn-at-startup no niri), o servidor parseia o foot.ini uma
# vez no boot e todo footclient herda aquela config -- o foot não tem reload em
# runtime. Sem isto, trocar de esquema atualizaria só as janelas já abertas (via
# ~/.config/noctalia/scripts/foot-apply-live.sh) e a próxima janela nasceria com o
# tema antigo.
#
# O payload é um punhado de sequências OSC geradas por aquele script a cada troca
# de esquema; aqui só o despejamos no terminal.

if status is-interactive; and string match -qr '^foot' -- "$TERM"
    set -l cache_dir $XDG_CACHE_HOME
    test -n "$cache_dir"; or set cache_dir $HOME/.cache
    set -l payload $cache_dir/noctalia/foot-live.osc
    test -r $payload; and command cat $payload
end
