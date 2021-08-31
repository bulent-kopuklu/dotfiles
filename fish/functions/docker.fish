function docker-rm
    docker rm (docker ps -aq)
end

function docker-clear
    docker rm (docker ps -aq)
end

function docker-reset
    docker rm (docker ps -aq)
end
