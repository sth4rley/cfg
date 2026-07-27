if status is-interactive
    # Commands to run in interactive sessions can go here
end

function nvd
    neovide $argv >/dev/null 2>&1 &
end

set -g fish_greeting ""
fish_add_path ~/.local/bin

set -x PYENV_ROOT $HOME/.pyenv
set -x PATH $PYENV_ROOT/bin $PATH
set -gx EDITOR nvim
pyenv init - | source


# Added by Antigravity CLI installer
set -gx PATH "/home/sth/.local/bin" $PATH
