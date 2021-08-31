set fish_greeting ""

set -x PATH /usr/.local/bin $PATH

function dlaudio
    youtube-dl -f bestaudio --extract-audio --audio-format mp3 $argv
end

function mdfind
    find ~/ -type f | fzf --bind "enter:execute(xdg-open {})" -q "$argv"
end

function pass
    gpg --gen-random --armor 1 30
end

alias vim "nvim"
alias vi "nvim"
alias open "xdg-open"

