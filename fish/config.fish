set fish_greeting ""

set -x PATH $HOME/.local/bin $PATH
#fish_add_path -m ~/.local/bin

function dlaudio
    youtube-dl -f bestaudio --extract-audio --audio-format mp3 $argv
end

#function mdfind
#    find ~/ -type f | fzf --bind "enter:execute(xdg-open {})" -q "$argv"
#end

#function pass
#    gpg --gen-random --armor 1 30
#end

function xsbt
    sbt -ivy "$XDG_DATA_HOME"/ivy2 -sbt-dir "$XDG_DATA_HOME"/sbt
end

function vm-start  
    VBoxManage startvm $argv --type headless
end

function vm-stop
    VBoxManage controlvm $argv acpipowerbutton
end

function vm-ls
    VBoxManage list -s runningvms
end

alias vim "nvim"
alias vi "nvim"
alias xopen "xdg-open"
alias d "docker"
alias dm "docker-machine"
alias ds "docker stack"
alias dc "docker-compose"
