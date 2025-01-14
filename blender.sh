#!/bin/bash

#===============================
# Blender Installer
# Author: MaheshTechnicals
#===============================

# Define colors for the UI
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

# Stylish header
echo -e "${CYAN}"
echo "############################################################"
echo "# Blender Installer                                          #"
echo "# Author: MaheshTechnicals                                   #"
echo "############################################################"
echo -e "${RESET}"

# Function to print a title
print_title() {
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"
    echo -e "${CYAN}$1${RESET}"
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Function to install dependencies
install_dependencies() {
    print_title "Installing Dependencies..."

    # Ensure wget, tar, and xz-utils are installed
    dependencies=(wget tar xz-utils)

    for dep in "${dependencies[@]}"; do
        if ! command_exists "$dep"; then
            echo -e "${YELLOW}$dep not found. Installing...${RESET}"
            sudo apt update
            sudo apt install -y "$dep"
        else
            echo -e "${GREEN}$dep is already installed.${RESET}"
        fi
    done
}

# Function to fetch the latest Blender version and download URL
fetch_blender_info() {
    print_title "Fetching Latest Blender Version..."

    # Fetch the latest Blender version and download URL from the official website
    response=$(curl -s 'https://www.blender.org/download/')
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Network request failed. Exiting...${RESET}"
        exit 1
    fi

    # Parse the response to extract the download URL
    download_url=$(echo "$response" | grep -oP 'href="\K(https://download.blender.org/release/[^"]+)"' | head -n 1)
    if [[ -z "$download_url" ]]; then
        echo -e "${RED}Failed to extract download URL. Exiting...${RESET}"
        exit 1
    fi

    # Extract the version number from the URL
    version=$(basename "$download_url" | sed -E 's/[^0-9]*([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
    echo -e "${CYAN}Latest Blender Version: $version${RESET}"
}

# Function to download and install Blender
download_and_install_blender() {
    print_title "Downloading and Installing Blender..."

    # Download Blender
    wget -q --show-progress "$download_url" -O "/tmp/blender.tar.xz"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to download Blender.${RESET}"
        exit 1
    fi

    # Ensure /opt directory exists
    sudo mkdir -p /opt

    # Remove old Blender folder if exists
    sudo rm -rf /opt/blender

    # Extract Blender into /opt/blender
    sudo tar -xvJf "/tmp/blender.tar.xz" -C /opt

    # Rename the extracted folder to 'blender'
    sudo mv /opt/$(basename "$download_url" .tar.xz) /opt/blender

    # Clean up the downloaded tar file
    rm "/tmp/blender.tar.xz"

    # Create symlink to /usr/local/bin
    create_symlink

    # Create Blender application menu entry
    create_menu_entry

    echo -e "${GREEN}Blender installation completed!${RESET}"
}

# Function to create symlink for Blender
create_symlink() {
    echo -e "${CYAN}Creating symlink to /usr/local/bin/blender...${RESET}"
    sudo ln -sf /opt/blender/blender /usr/local/bin/blender
}

# Function to create Blender application menu entry
create_menu_entry() {
    echo -e "${CYAN}Creating Blender application menu entry...${RESET}"
    sudo bash -c 'cat > /usr/share/applications/blender.desktop' << EOF
[Desktop Entry]
Name=Blender
Comment=Blender 3D Creation Suite
Exec=/opt/blender/blender %F
Icon=/opt/blender/blender.svg
Terminal=false
Type=Application
Categories=Graphics;3DGraphics;
EOF
}

# Function to uninstall Blender
uninstall_blender() {
    print_title "Uninstalling Blender..."

    # Remove the symlink
    sudo rm -f /usr/local/bin/blender

    # Remove the Blender folder
    sudo rm -rf /opt/blender

    # Remove the application menu entry
    sudo rm -f /usr/share/applications/blender.desktop

    echo -e "${GREEN}Blender uninstalled successfully!${RESET}"
}

# Function to check Blender installation
check_blender() {
    if command_exists blender; then
        echo -e "${GREEN}Blender installed successfully!${RESET}"
        blender --version
    else
        echo -e "${RED}Blender executable not found.${RESET}"
    fi
}

# Main Menu
echo -e "${CYAN}1. Install Blender
2. Uninstall Blender
3. Check Blender installation${RESET}"
read -p "Enter your choice: " choice

case $choice in
    1)
        install_dependencies
        fetch_blender_info
        download_and_install_blender
        ;;
    2)
        uninstall_blender
        ;;
    3)
        check_blender
        ;;
    *)
        echo -e "${RED}Invalid choice!${RESET}"
        ;;
esac

