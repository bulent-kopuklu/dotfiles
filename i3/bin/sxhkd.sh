#! /usr/bin/env bash

cmdlog="$XDG_CACHE_HOME/sxhkd/cmdlog"

while pgrep -x sxhkd > /dev/null;
    pgrep sxhkd | xargs kill -9
    do sleep 1
done

exec sxhkd -t 2 -r "$cmdlog" > "$XDG_CACHE_HOME/sxhkd/stdout" 2> "$XDG_CACHE_HOME/sxhkd/stderr"
