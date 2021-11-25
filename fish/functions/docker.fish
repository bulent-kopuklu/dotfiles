function d-rmi
    docker rmi -f (docker images | grep $argv | awk '{print $3}')
end

function d-clear
    docker rm (docker ps -aq)
end

function d-reset
    docker stop (docker ps -aq)
    docker rm (docker ps -aq)
    docker rmi -f (docker images | awk '{print $3}')
    docker system prune -a -f
end
