#!/bin/bash
trap 'cleanup' EXIT
set -e
# Setting up Variables ===============================================

themes_dir="$HOME/.themes"
icons_dir="$HOME/.icons"


# TODO
# initiate GTK dark mode and apply icon and cursor theme
# gsettings set org.gnome.desktop.interface color-scheme prefer-dark > /dev/null 2>&1 &
# gsettings set org.gnome.desktop.interface gtk-theme Tokyonight-Dark-BL-LB > /dev/null 2>&1 &
# gsettings set org.gnome.desktop.interface icon-theme Tokyonight-Dark > /dev/null 2>&1 &
# gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Ice > /dev/null 2>&1 &
# gsettings set org.gnome.desktop.interface cursor-size 24 > /dev/null 2>&1 &

# Functions ====================================================

# Echo with colors
echolorize() {

    # Maintain local

    local color=$1
    local message=$2

    local green='\033[0;32m'
    local red='\033[0;31m'
    local blue='\033[0;34m'
    local noColor='\033[0m'

    # Default colors
    case $color in
        "red")      colorize="$red";; 
        "green")    colorize="$green";;
        "blue")     colorize="$blue";;
        *)
            echo "Unknown color:: $color"
            return;;
    esac

    echo -e "${colorize}[~] $message [~]${noColor}"
}

# Download from GitHub
download_conf() {
    local base_url="https://raw.githubusercontent.com/catppuccin/kitty/main/themes"

    # Create directory to store downloaded files
    mkdir -p "$PWD/kitty-themes"
    cd kitty-themes/

    # List files in the themes directory of the GitHub repository
    files=$(curl -s "https://api.github.com/repos/catppuccin/kitty/contents/themes" | jq -r '.[].name')

    # Download each file
    for file in $files; do
        # Check if the file is a directory
        if [ "$file" != "README.md" ]; then
            echo "Downloading $file..."
            curl -sOL "$base_url/$file"
            echo "$file downloaded."
        fi
    done

    echo "Finished downloading."
}


# Download from Git Hub
download_zip() {

    mkdir -p "$PWD/gtk-catppuccin" || { echolorize "red" "Failed to create directory."; return 1; }
    cd gtk-catppuccin/ || { echolorize "red" "Failed to change directory."; return 1; }

    # Get the latest release information
    release_info=$(curl -s https://api.github.com/repos/catppuccin/gtk/releases/latest)

    # Extract download URLs using jq
    download_urls=$(echo "$release_info" | jq -r '.assets[].browser_download_url')

    # Download each file
    for url in $download_urls; do

        # Get only filename to check if is already there
        filename=$(basename "$url")

        # Check filename in currenty folder
        if [ ! -f "$PWD/$filename" ]; then

            # Download if !(exist)
            wget -q "$url"  && echolorize "green" "$filename Downloaded!"
        else
            # Ignore if (exist)
            echolorize "red" "$filename already downloaded. Skipped!"
        fi
    done

    echolorize "green" "Finished downloading!"

}

# Starship > zsh
install_starship() {
    curl -sS https://starship.rs/install.sh | sh
    echo "eval \"\$(starship init bash)\"" >> "$HOME"/.bashrc
    starship preset nerd-font-symbols -o ~/.config/starship.toml

}

# Code run ===========================================================

echolorize "blue" "Updating system..."
sudo dnf update -y

echolorize "blue" "Installing dependencies..."

dependencies_file="dependencies"
install_command="sudo dnf install -y"

if [ ! -f "$dependencies_file" ]; then
    echolorize "red" "Dependencies file '$dependencies_file' not found!"
    exit 1
fi

$install_command $(cat "$dependencies_file")

# -- Installing Catppuccin GTK Theme --
echolorize "blue" "Installing Catppuccin GTK Theme..."

download_zip &&
unzip -q '*.zip' -x '*hdpi*' &&
mv * "$themes_dir/" &&
sleep 10 &&

echolorize "green" "Catppuccin GTK Installed!"
cd .. && rm -Rf gtk-catppuccin/

# -- Installing Catppuccin Qt5ct Theme --
echolorize "blue" "Installing Catppuccin GTK Theme..."
git clone https://github.com/catppuccin/qt5ct/
cd qt5ct/themes &&
mv * ~/.config/qt5ct/colors/ &&
echolorize "green" "Catppuccin qt5ct Installed!"

# -- Installing Catppuccin Kitty Theme --
echolorize "blue" "Installing Catppuccin Kitty Theme..."

download_conf &&
mv * ~/.config/kitty/themes &&
sleep 5 &&


echolorize "green" "Catppuccin Kitty Installed!"
cd .. && rm kitty-themes/


# -- Installing Catppuccin Kvantum Theme --
echolorize "blue" "Installing Catppuccin Kvantum Theme..."

git clone https://github.com/catppuccin/Kvantum &&
cd Kvantum/src

kvantum_theme="Catppuccin-Macchiato-Flamingo"
mv * ~/.config/Kvantum/ &&
kvantummanager --set "$kvantum_theme" > /dev/null 2>&1 &&
sleep 5 # Wait for the process to finish installing

echolorize "green" "Catppuccin Kvantum Theme installed!"

# -- Installing McMuse-Circle Icon theme --
echolorize "blue" "Installing McMuse-Circle icon theme..."

git clone https://github.com/yeyushengfan258/McMuse-circle &&
cd McMuse-circle/ &&
./install.sh &&
sleep 5 &&

echolorize "green" "McMuse Icon Theme Installed!"
cd .. && rm -Rf McMuse-circle/

# -- Installing Feral Gamemode --
echolorize "blue" "Installing Feral Gamemode..."

git clone https://github.com/FeralInteractive/gamemode.git &&
cd gamemode &&
git checkout 1.8.1 && # omit to build the master branch
./bootstrap.sh &&
sleep 5 &&

echolorize "green" "Feral Gamemode installed!"
# Adding user to gamemode group to avoid errors
sudo usermod -a -G gamemode $USER

gamemoded -t
sleep 10
clear