#! /usr/bin/env bash

status() {
    MUTED=$(pacmd list-sources | awk '/\*/,EOF {print}' | awk '/muted/ {print $2; exit}')
    icon="#FE57C46"
    
    if [ "$MUTED" = "yes" ]; then
        echo "%{F#FE57C46}%{F-}"
        
    else
        echo ""
    fi
}

clearPreviousInstance() {
    name = ${BASH_SOURCE[0]}
    for pid in $(pidof -x $name); do
      if [ $pid != $$ ]; then
        kill -9 $pid
      fi
    done
}

listen() {
    clearPreviousInstance
    status

    LANG=EN; pactl subscribe | while read -r event; do
        if echo "$event" | grep -q "source" || echo "$event" | grep -q "server"; then
            status
        fi
    done
}

toggle() {
  MUTED=$(pacmd list-sources | awk '/\*/,EOF {print}' | awk '/muted/ {print $2; exit}')
  DEFAULT_SOURCE=$(pacmd list-sources | awk '/\*/,EOF {print $3; exit}')

  if [ "$MUTED" = "yes" ]; then
      pacmd set-source-mute "$DEFAULT_SOURCE" 0
  else
      pacmd set-source-mute "$DEFAULT_SOURCE" 1
  fi
}

case "$1" in
    --toggle)
        toggle
        ;;
    *)
        listen
        ;;
esac
