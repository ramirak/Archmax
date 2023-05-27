#!/bin/bash

USERNAME=$(whoami)

function CheckConnectivity() {
    echo "Testing connectivity to the internet.."
    if ping -q -w 1 -c 1 8.8.8.8 > /dev/null; then
        echo "Connection succeeded." 
    else
        echo "No internet connection. exiting."
        exit 0
    fi
}

function SetPre() {
    read -n1 -rep 'Would you like to start the setup process? (y,n)' R
    if [[ $R != "Y" && $R != "y" ]]; then
        exit 0
    fi

    # Root required for installations
    if [ "$EUID" -ne 0 ]
        then echo "Please run me as root!"
        exit
    fi

    # Regret time
    echo "Installation process will start in:"
    for i in 5 4 3 2 1 ; do    
        echo "$i.."
        sleep 1
    done
}

# Install dependencies 
function SetDepend() {
    echo "Setting up git & yay.."
    pacman -S --noconfirm git
    git clone https://aur.archlinux.org/yay-git.git /opt
    chown -R $USERNAME:$USERNAME ./yay-git
    makepkg -si /opt/yay-git
    yay -Syu
}

# Add blackarch repository 
function SetBlackArch() {
    echo "Adding black-arch repository.."
    curl -O https://blackarch.org/strap.sh
    chmod +x strap.sh
    ./strap.sh
}

# Setup Hyprland
function SetHypr() {
    yay -S --noconfirm hyprland kitty waybar-hyprland \
    swaybg swaylock-effects wofi wlogout mako thunar neofetch \
    ttf-jetbrains-mono-nerd noto-fonts-emoji \
    polkit-gnome swappy grim slurp pamixer brightnessctl gvfs \
    bluez bluez-utils lxappearance xfce4-settings \
    dracula-gtk-theme sweet-cursors-theme-git sweet-folders-icons-git xdg-desktop-portal-hyprland-git

    cp -R -t ~/.config hypr kitty mako waybar swaylock wofi neofetch wallpapers
    chmod +x ~/.config/hypr/xdg-portal-hyprland
}

# Setup Neovim
function SetNvim() {
    echo "Installing Neovim and py dependencies.."
    yay -S --noconfirm nvim ctags jedi
    cp nvim/init.vim ~/.config/nvim/init.vim
    # Install plugin system
    echo "Installing plugin system.." 
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    nvim -c PlugInstall

    echo "Setting up IDE.."
    yay -S --noconfirm clangd
    echo "Setting C.."
    nvim -c CocInstall coc-clang
    nvim -c CocInstall coc-cmake
    echo "Setting bash.."
    nvim -c CocInstall coc-sh
    echo "Setting python.."
    nvim -c cocinstall coc-python
    echo {"clangd.path": "/usr/bin/clangd"} > ~/.config/nvim/coc-settings.json
}

# Install Fish Shell
function SetFish(){
    echo "Installing fish shell.."
    yay -S --noconfirm fish
    echo "Setting fish shell as default.."
    chsh -s /usr/bin/fish
    echo "Copying configuration file.."
    cp config.fish ~/.config/fish/config.fish
}

# Audio
function SetAudio() {
    echo "Installing easyeffects.."
    yay -S --noconfirm easyeffects
}

# Graphics Card
function SetGPU() {
    echo "Checking for external GPU.."
    if [ `lspci | grep ATI | wc -l` -gt 0 ] ; then
        echo "Setting AMD graphic card support.."
        yay -S --noconfirm xf86-video-amdgpu mesa
        sed -i '/MODULES/d' /etc/mkinitcpio.conf
        echo MODULES=\(amdgpu\) >> /etc/mkinitcpio.d
        echo "options amdgpu si_support=1" > /etc/modprobe.d/amdgpu.conf
        echo "options amdgpu cik_support=1" >> /etc/modprobe.d/amdgpu.conf
        echo "options radeon si_support=0" > /etc/modprobe.d/radeon.conf
        echo "options radeon cik_support=0" >> /etc/modprobe.d/radeon.conf
        echo "blacklist radeon" >> /etc/modprobe.d/radeon.conf
    elif [ `lspci | grep nvidia | wc -l` -gt 0 ] ; then
        echo "Setting Nvidia graphic card support.."
        pacman -S --noconfirm nvidia nvidia-settings lib32-nvidia-utils
        sed -i '/MODULES/d' /etc/mkinitcpio.conf
        echo MODULES=\(nvidia nvidia_modeset nvidia_uvm nvidia_drm\) >> /etc/mkinitcpio.conf
    else
        echo "No external GPU found."
        return 0
    fi
    mkinitcpio -P
}

function CheckRet() {
    if [ "$?" -ne 0 ]
        then echo "Failure, exiting.."
        exit
    fi
}

function Try(){
    $1 
    CheckRet
}

# Start All
Try CheckConnectivity
Try SetPre
Try SetDepend
Try SetBlackArch
Try Hyprland
Try SetNeovim
Try SetFish
Try SetAudio
Try SetGPU

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Installation finished succesfully! Enjoy!"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

