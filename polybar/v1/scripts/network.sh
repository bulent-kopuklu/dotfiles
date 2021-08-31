#! /usr/bin/env bash

networkWifi() {
    echo 'wifi'
}

networkEth() {
    echo 'eth'
}

networkOffline() {
    echo 'offline'
}

network_print() {
    wifi=0
    eth=0
    default=$(route 2>/dev/null | awk '/default/ {print $8}') 
    if [ -n "$default" ]; then
        connection_list=$(nmcli -t -f name,type,device,state connection show --active 2>/dev/null | grep -v ':bridge:')

        if [ -n "$connection_list" ] && [ "$(echo "$connection_list" | wc -l)" -gt 0  ]; then
            IFS=$'\n'
            for line in echo $connection_list; do
                i=$(echo $line | awk -F':' '{print $3}')
                
                if [ "$i" == "$default" ]; then
                    c=$(echo $line | awk -F':' '{print $1}')
                    t=$(echo $line | awk -F':' '{print $2}')
                    
                    if [ "$t" == "802-11-wireless" ]; then
                        echo "%{F#E57C46}%{F-} $c"
                    elif [ "$t" == "802-3-ethernet" ]; then
                        echo "%{F#E57C46}%{F-}"
                    fi
                fi
            done
        fi
    else
        echo "%{F#EC7875} Offline%{F-}"
    fi
}

network_update() {
    pid=$(cat "$path_pid")

    if [ "$pid" != "" ]; then
        kill -10 "$pid"
    fi
}

path_pid="/tmp/polybar-network-networkmanager.pid"

case "$1" in --update)
        network_update
        ;;
    *)
        echo $$ > $path_pid

        trap exit INT
        trap "echo" USR1

        while true; do
            network_print

            sleep 10 &
            wait
        done
        ;;
esac
                                                         