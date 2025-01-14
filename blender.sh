#!/bin/bash

# Function to check and install dependencies
install_dependency() {
    package=$1
    if ! dpkg -l | grep -q "$package"; then
        echo "$package not found, installing..."
        sudo apt-get install -y "$package"
    else
        echo "$package is already installed, skipping."
    fi
}

# Install dependencies if not already installed
install_dependency "curl"
install_dependency "grep"
install_dependency "sed"
install_dependency "tac"
install_dependency "tar"
install_dependency "xz-utils"
install_dependency "wget"

# Define the base URL
base_url="https://download.blender.org/release/"

# Function to install Blender
install_blender() {
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

    # Output the result
    echo "Blender Title: $blender_title"
    echo "Blender URL: $blender_url"

    # Download the Blender tarball using wget with dot-style progress (single line)
    echo "Downloading Blender..."
    wget --progress=dot -O "$blender_title" "$blender_url"

    # Ensure /opt exists before extracting Blender
    echo "Ensuring /opt directory exists..."
    sudo mkdir -p /opt/blender

    # Remove the old Blender folder (if it exists)
    echo "Removing old Blender folder in /opt..."
    sudo rm -rf /opt/blender/*

    # Extract Blender into /opt/blender
    echo "Extracting Blender into /opt/blender..."
    sudo tar -xJf "$blender_title" -C /opt/blender

    # Rename the extracted directory to "blender"
    echo "Renaming extracted directory to 'blender'..."
    sudo mv /opt/blender/blender-4.3.2-linux-x64 /opt/blender/blender

    # List the extracted directory structure to check the executable's location
    echo "Listing extracted files in /opt/blender/"
    ls -l /opt/blender/blender

    # Check the presence of the blender executable
    if [ -f "/opt/blender/blender/blender" ]; then
        echo "Blender executable found at /opt/blender/blender/blender"
    else
        echo "Blender executable not found in expected location."
        exit 1
    fi

    # Create a symbolic link for easier access
    echo "Creating symlink to /usr/local/bin..."
    sudo ln -sf /opt/blender/blender/blender /usr/local/bin/blender

    # Create a Blender .desktop entry for the App Menu
    echo "Creating Blender application menu entry..."
    desktop_file="/usr/share/applications/blender.desktop"

    sudo bash -c "cat > $desktop_file <<EOF
[Desktop Entry]
Name=Blender
Comment=3D creation suite
Exec=/opt/blender/blender/blender %F
Icon=/opt/blender/blender/blender.svg
Terminal=false
Type=Application
Categories=Graphics;3DGraphics;
EOF"

    # Clean up the tarball
    rm "$blender_title"

    # Verify installation
    echo "Blender installation completed!"
    blender --version
}

# Function to uninstall Blender
uninstall_blender() {
    echo "Uninstalling Blender..."

    # Remove the symbolic link
    sudo rm -f /usr/local/bin/blender

    # Remove the .desktop entry
    sudo rm -f /usr/share/applications/blender.desktop

    # Remove the extracted Blender directory
    sudo rm -rf /opt/blender

    echo "Blender uninstalled successfully!"
}

# Function to show the menu
show_menu() {
    echo "Choose an option:"
    echo "1. Install Blender"
    echo "2. Uninstall Blender"
    echo "3. Exit"
    read -p "Enter your choice: " choice
    case $choice in
        1)
            install_blender
            ;;
        2)
            uninstall_blender
            ;;
        3)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option, please try again."
            show_menu
            ;;
    esac
}

# Run the menu
show_menu

