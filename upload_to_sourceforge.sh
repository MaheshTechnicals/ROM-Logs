#!/bin/bash

#===============================#
#      SourceForge Uploader      #
#   Script by MaheshTechnicals  #
#===============================#

# Define colors for the UI
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

# Stylish header
echo -e "${CYAN}"
echo "############################################################"
echo "#                SourceForge Uploader Script                #"
echo "#               Author: MaheshTechnicals                  #"
echo "############################################################"
echo -e "${RESET}"

# Function to print a title
print_title() {
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"
    echo -e "${CYAN}$1${RESET}"
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"
}

# Function to check if scp is installed
check_scp() {
    if ! command -v scp &> /dev/null; then
        echo -e "${RED}scp command not found. Please install OpenSSH.${RESET}"
        exit 1
    fi
}

# Function to upload the file to SourceForge
upload_file() {
    print_title "Uploading file to SourceForge..."

    # Ensure scp is installed
    check_scp

    read -p "Enter your SourceForge username: " username
    read -sp "Enter your SourceForge password: " password
    echo

    read -p "Enter the path to the file you want to upload: " file_path
    read -p "Enter the destination directory on SourceForge (e.g., /home/username/): " destination

    # Check if file exists
    if [[ ! -f "$file_path" ]]; then
        echo -e "${RED}Error: File does not exist! Exiting...${RESET}"
        exit 1
    fi

    # Start upload
    echo -e "${CYAN}Starting upload...${RESET}"
    scp "$file_path" "$username@frs.sourceforge.net:$destination"

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}File uploaded successfully to SourceForge!${RESET}"
    else
        echo -e "${RED}Error: File upload failed. Please try again.${RESET}"
    fi
}

# Function to show the script menu
show_menu() {
    while true; do
        clear
        echo -e "${CYAN}############################################################${RESET}"
        echo -e "${CYAN}#                SourceForge Uploader Script                #${RESET}"
        echo -e "${CYAN}#               Author: MaheshTechnicals                  #${RESET}"
        echo -e "${CYAN}############################################################${RESET}"

        echo -e "${YELLOW}1. Upload File to SourceForge${RESET}"
        echo -e "${YELLOW}2. Exit${RESET}"

        read -p "Choose an option: " choice
        case $choice in
            1)
                upload_file
                ;;
            2)
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please try again.${RESET}"
                read -r -p "Press any key to continue..."
                ;;
        esac
    done
}

# Call show_menu function to display the menu
show_menu

