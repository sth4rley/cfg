#!/bin/bash
function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}
$HOME/.config/polybar/launch.sh &

keybLayout=$(setxkbmap -v | awk -F "+" '/symbols/ {print $2}')

run sxhkd -c ~/.config/bspwm/sxhkdrc &
xsetroot -cursor_name left_ptr &
run nm-applet &
blueberry-tray &
picom --config $HOME/.config/bspwm/picom.conf &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
nitrogen --restore &
xsetroot -cursor_name left_ptr &
