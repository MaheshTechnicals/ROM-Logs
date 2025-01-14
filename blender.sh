#!/bin/bash

# Function to print a header in bold blue
print_header() {
    tput bold
    tput setaf 4
    echo "$1"
    tput sgr0
}

# Function to print a section header in bold green
print_section_header() {
    tput bold
    tput setaf 2
    echo "$1"
    tput sgr0
}

# Function to install dependencies
install_dependencies() {
    print_section_header "Step 1: Installing Dependencies"

    # Ensure wget, tar, and xz-utils are installed
    dependencies=(wget tar xz-utils)

    for dep in "${dependencies[@]}"; do
        if ! command -v $dep &> /dev/null; then
            echo "$dep not found. Installing..."
            sudo apt update
            sudo apt install -y $dep
        else
            echo "$dep is already installed."
        fi
    done
}

# Function to download and install Blender
download_and_install_blender() {
    print_section_header "Step 2: Downloading and Installing Blender"

    base_url="https://download.blender.org/release/"
    
    # Fetch the main page and extract directories that match the Blender version pattern
    blender_dirs=$(curl -s "$base_url" | grep -oP 'href="Blender\s*\d+\.\d+[^"]+"' | sed -E 's/href="([^"]+)"/\1/' | grep -E '^Blender')

    # Reverse the list of directories
    blender_dirs_reversed=$(echo "$blender_dirs" | tac)

    # Get the first reversed directory
    first_reversed_dir=$(echo "$blender_dirs_reversed" | head -n 1)

    # Construct the full release URL for that directory
    release_url="${base_url}${first_reversed_dir}"

    # Fetch the release page for the first reversed directory
    release_page=$(curl -s "$release_url")

    # Extract .tar.xz file links and their titles
    tar_xz_files=$(echo "$release_page" | grep -oP 'href="([^"]+\.tar\.xz)"' | sed -E 's/href="([^"]+)"/\1/')

    # Reverse the list of .tar.xz file links
    tar_xz_files_reversed=$(echo "$tar_xz_files" | tac)

    # Get the first reversed .tar.xz file URL
    first_tar_xz_file=$(echo "$tar_xz_files_reversed" | head -n 1)

    # Construct the full URL for the .tar.xz file
    blender_url="${release_url}${first_tar_xz_file}"

    # Extract the title of the .tar.xz file from the link text (assuming it's the file name)
    blender_title=$(basename "$first_tar_xz_file")

    # Download Blender
    echo "Downloading Blender..."
    wget -q --show-progress "$blender_url" -O "/tmp/$blender_title"

    # Ensure /opt directory exists
    echo "Ensuring /opt directory exists..."
    sudo mkdir -p /opt

    # Remove old Blender folder if exists
    echo "Removing old Blender folder in /opt..."
    sudo rm -rf /opt/blender

    # Extract Blender into /opt/blender
    echo "Extracting Blender into /opt/blender..."
    sudo tar -xvJf "/tmp/$blender_title" -C /opt

    # Rename the extracted folder to 'blender'
    echo "Renaming extracted directory to 'blender'..."
    sudo mv /opt/$(basename "$blender_title" .tar.xz) /opt/blender

    # Clean up the downloaded tar file
    echo "Removing downloaded tar file..."
    rm "/tmp/$blender_title"

    # Create symlink to /usr/local/bin
    create_symlink

    # Create Blender application menu entry
    create_menu_entry

    echo "Blender installation completed!"
}

# Function to create symlink for Blender
create_symlink() {
    print_section_header "Step 3: Creating Symlink"

    # Create a symbolic link to the Blender executable
    echo "Creating symlink to /usr/local/bin/blender..."
    sudo ln -sf /opt/blender/blender /usr/local/bin/blender
}

# Function to create Blender application menu entry
create_menu_entry() {
    print_section_header "Step 4: Creating Application Menu Entry"

    # Create a .desktop file for Blender in application menu
    echo "Creating Blender application menu entry..."
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
    print_section_header "Step 5: Uninstalling Blender"

    echo "Uninstalling Blender..."
    
    # Remove the symlink
    sudo rm -f /usr/local/bin/blender
    
    # Remove the Blender folder
    sudo rm -rf /opt/blender
    
    # Remove the application menu entry
    sudo rm -f /usr/share/applications/blender.desktop
    
    echo "Blender uninstalled successfully!"
}

# Function to check Blender installation
check_blender() {
    print_section_header "Step 6: Checking Blender Installation"

    if command -v blender &> /dev/null; then
        echo "Blender installed successfully!"
        blender --version
    else
        echo "Blender executable not found."
    fi
}

# Main Menu
print_header "Blender Installer Script"
echo "Author: Mahesh Technicals"
echo ""
echo "1. Install Blender"
echo "2. Uninstall Blender"
echo "3. Check Blender installation"
read -p "Enter your choice: " choice

case $choice in
    1)
        install_dependencies
        download_and_install_blender
        ;;
    2)
        uninstall_blender
        ;;
    3)
        check_blender
        ;;
    *)
        echo "Invalid choice!"
        ;;
esac

