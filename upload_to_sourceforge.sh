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

# Function to read credentials from private.json
read_credentials() {
    if [ ! -f "private.json" ]; then
        echo -e "${RED}Error: private.json file not found! Exiting...${RESET}"
        exit 1
    fi

    username=$(jq -r '.username' private.json)
    project=$(jq -r '.project' private.json)

    if [ -z "$username" ] || [ -z "$project" ]; then
        echo -e "${RED}Error: Missing 'username' or 'project' in private.json. Exiting...${RESET}"
        exit 1
    fi
}

# Function to list .img and .zip files in the current directory with numbering
list_files() {
    echo -e "${CYAN}Listing .img and .zip files in the current directory...${RESET}"

    files=$(find . -type f \( -name "*.img" -o -name "*.zip" \))
    
    if [ -z "$files" ]; then
        echo -e "${RED}No .img or .zip files found in the current directory.${RESET}"
        exit 1
    fi

    count=1
    echo -e "${CYAN}Files found:${RESET}"
    for file in $files; do
        echo -e "${YELLOW}$count. $file${RESET}"
        count=$((count + 1))
    done
}

# Function to upload a single file to SourceForge
upload_single_file() {
    print_title "Uploading Single File to SourceForge..."

    # Ensure scp is installed
    check_scp

    # Read credentials from private.json
    read_credentials

    echo -e "${CYAN}Using SourceForge username: $username${RESET}"
    echo -e "${CYAN}Project: $project${RESET}"

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

# Function to upload selected files to SourceForge
upload_selected_files() {
    print_title "Uploading Selected Files to SourceForge..."

    # Ensure scp is installed
    check_scp

    # Read credentials from private.json
    read_credentials

    echo -e "${CYAN}Using SourceForge username: $username${RESET}"
    echo -e "${CYAN}Project: $project${RESET}"

    read -sp "Enter your SourceForge password: " password
    echo

    # List .img and .zip files
    list_files

    read -p "Enter the numbers of the files to upload, separated by space (e.g., 1 3 5): " selected_files
    read -p "Enter the destination directory on SourceForge (e.g., /home/username/): " destination

    for num in $selected_files; do
        # Get the file path corresponding to the number
        file_path=$(echo "$files" | sed -n "${num}p")

        # Check if file exists
        if [[ ! -f "$file_path" ]]; then
            echo -e "${RED}Error: File $file_path does not exist! Skipping...${RESET}"
            continue
        fi

        # Start upload
        echo -e "${CYAN}Uploading $file_path...${RESET}"
        scp "$file_path" "$username@frs.sourceforge.net:$destination"

        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}$file_path uploaded successfully!${RESET}"
        else
            echo -e "${RED}Error uploading $file_path.${RESET}"
        fi
    done
}

# Function to upload all files to SourceForge
upload_all_files() {
    print_title "Uploading All Files to SourceForge..."

    # Ensure scp is installed
    check_scp

    # Read credentials from private.json
    read_credentials

    echo -e "${CYAN}Using SourceForge username: $username${RESET}"
    echo -e "${CYAN}Project: $project${RESET}"

    read -sp "Enter your SourceForge password: " password
    echo

    # List .img and .zip files
    list_files

    read -p "Enter the destination directory on SourceForge (e.g., /home/username/): " destination

    # Upload each file
    for file in $files; do
        echo -e "${CYAN}Uploading $file...${RESET}"
        scp "$file" "$username@frs.sourceforge.net:$destination"

        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}$file uploaded successfully!${RESET}"
        else
            echo -e "${RED}Error uploading $file.${RESET}"
        fi
    done
}

# Function to show the script menu
show_menu() {
    while true; do
        clear
        echo -e "${CYAN}############################################################${RESET}"
        echo -e "${CYAN}#                SourceForge Uploader Script                #${RESET}"
        echo -e "${CYAN}#               Author: MaheshTechnicals                  #${RESET}"
        echo -e "${CYAN}############################################################${RESET}"

        echo -e "${YELLOW}1. Upload a Single File to SourceForge${RESET}"
        echo -e "${YELLOW}2. Upload Selected Files to SourceForge${RESET}"
        echo -e "${YELLOW}3. Upload All Files to SourceForge${RESET}"
        echo -e "${YELLOW}4. Upload a File by Custom Path${RESET}"
        echo -e "${YELLOW}5. Exit${RESET}"

        read -p "Choose an option: " choice
        case $choice in
            1)
                upload_single_file
                ;;
            2)
                upload_selected_files
                ;;
            3)
                upload_all_files
                ;;
            4)
                upload_single_file
                ;;
            5)
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

