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

# Define the base URL
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

# Output the result
echo "Blender Title: $blender_title"
echo "Blender URL: $blender_url"

# Download the Blender tarball
echo "Downloading Blender..."
curl -L "$blender_url" -o "$blender_title"

# Extract the tarball
echo "Extracting Blender..."
tar -xJf "$blender_title" -C /opt

# Create a symbolic link for easier access
echo "Creating symlink to /usr/local/bin..."
sudo ln -sf "/opt/$(basename "$blender_title" .tar.xz)/blender" /usr/local/bin/blender

# Create a Blender .desktop entry for the App Menu
echo "Creating Blender application menu entry..."
desktop_file="/usr/share/applications/blender.desktop"

sudo bash -c "cat > $desktop_file <<EOF
[Desktop Entry]
Name=Blender
Comment=3D creation suite
Exec=/opt/$(basename "$blender_title" .tar.xz)/blender %F
Icon=/opt/$(basename "$blender_title" .tar.xz)/blender.svg
Terminal=false
Type=Application
Categories=Graphics;3DGraphics;
EOF"

# Clean up the tarball
rm "$blender_title"

# Verify installation
echo "Blender installation completed!"
blender --version

