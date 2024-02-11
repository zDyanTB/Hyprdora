#!/bin/bash
trap 'cleanup' EXIT
set -e
# Setting up Variables ===============================================

themes_dir="$HOME/.themes"
icons_dir="$HOME/.icons"

# TODO
# DOWNLOAD
# jq
# curl
# git
# unzip

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


# Download from Git Hub
download_themes() {

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

# Installing Catppuccin GTK Theme
echolorize "blue" "Installing Catppuccin GTK Theme..."

download_themes &&
unzip -q '*.zip' -x '*hdpi*' &&
mv * "$themes_dir/" &&

echolorize "green" "Catppuccin GTK Installed!"
cd .. && rm -Rf gtk-catppuccin/

# Installing McMuse-Circle Icon theme
echolorize "blue" "Installing McMuse-Circle icon theme..."

git clone https://github.com/yeyushengfan258/McMuse-circle &&
cd McMuse-circle/ &&
./install.sh &&

echolorize "green" "McMuse Icon Theme Installed!"
cd .. && rm -Rf McMuse-circle/