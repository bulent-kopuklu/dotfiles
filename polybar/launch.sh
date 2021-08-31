#! /usr/bin/env bash

DIR="$HOME/.config/polybar/current"

while pgrep -x polybar > /dev/null;
    pgrep polybar | xargs kill -9
    do sleep 1
done

for m in $(polybar --list-monitors | cut -d":" -f1); do
    MONITOR=$m polybar -q main -c $DIR/config.ini &
done