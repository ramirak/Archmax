alias vim='nvim'
alias amd='DRI_PRIME=1'

function wifi
     nmcli device wifi connect $argv --ask
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        exec Hyprland -- -keeptty
    end
end

neofetch
