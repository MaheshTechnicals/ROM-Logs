#!/bin/bash

# Script to decompile APK, change package name, and rebuild it

# Function to display usage
usage() {
    echo "Usage: $0 <path_to_apk> <old_package_name> <new_package_name>"
    echo "Example: $0 /path/to/app.apk com.example.old com.example.new"
    exit 1
}

# Check if correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    usage
fi

# Variables
APK_PATH=$1
OLD_PACKAGE_NAME=$2
NEW_PACKAGE_NAME=$3
WORK_DIR="apk_work"
KEYSTORE_FILE="my-release-key.keystore"
KEY_ALIAS="my-key-alias"
KEYSTORE_PASS="password"

# Function to install required packages
install_dependencies() {
    echo "Checking for required dependencies..."
    if ! command -v apktool &> /dev/null; then
        echo "Installing apktool..."
        sudo apt update && sudo apt install apktool -y
    else
        echo "apktool is already installed."
    fi
    if ! command -v jarsigner &> /dev/null; then
        echo "Installing jarsigner..."
        sudo apt update && sudo apt install openjdk-11-jdk -y
    else
        echo "jarsigner is already installed."
    fi
    if ! command -v keytool &> /dev/null; then
        echo "Installing keytool..."
        sudo apt update && sudo apt install openjdk-11-jdk -y
    else
        echo "keytool is already installed."
    fi
    echo "All dependencies are installed."
}

# Function to decompile APK
decompile_apk() {
    echo "Decompiling APK..."
    apktool d "$APK_PATH" -o "$WORK_DIR" --force
    if [ $? -ne 0 ]; then
        echo "Error: Failed to decompile APK!"
        exit 1
    fi
    echo "Decompilation successful!"
}

# Function to change package name
change_package_name() {
    echo "Changing package name from $OLD_PACKAGE_NAME to $NEW_PACKAGE_NAME..."
    
    # Update the package name in the AndroidManifest.xml
    sed -i "s/${OLD_PACKAGE_NAME}/${NEW_PACKAGE_NAME}/g" "$WORK_DIR/AndroidManifest.xml"

    # Update package declarations in smali files
    OLD_PACKAGE_DIR=$(echo "$OLD_PACKAGE_NAME" | tr '.' '/')
    NEW_PACKAGE_DIR=$(echo "$NEW_PACKAGE_NAME" | tr '.' '/')

    # Rename smali directories
    if [ -d "$WORK_DIR/smali/$OLD_PACKAGE_DIR" ]; then
        echo "Renaming smali directories..."
        mkdir -p "$WORK_DIR/smali/$(dirname $NEW_PACKAGE_DIR)"
        mv "$WORK_DIR/smali/$OLD_PACKAGE_DIR" "$WORK_DIR/smali/$NEW_PACKAGE_DIR"
    fi

    # Replace old package name with new package name in smali files
    echo "Updating smali files..."
    find "$WORK_DIR/smali" -type f -name "*.smali" -exec sed -i "s/L${OLD_PACKAGE_NAME//./\\/}/L${NEW_PACKAGE_NAME//./\\/}/g" {} +
    find "$WORK_DIR/smali" -type f -name "*.smali" -exec sed -i "s/${OLD_PACKAGE_NAME//./\\/}/${NEW_PACKAGE_NAME//./\\/}/g" {} +

    echo "Package name changed successfully!"
}

# Function to rebuild APK
rebuild_apk() {
    echo "Rebuilding APK..."
    apktool b "$WORK_DIR" -o new_app.apk
    if [ $? -ne 0 ]; then
        echo "Error: Failed to rebuild APK!"
        exit 1
    fi
    echo "Rebuild successful! APK is saved as 'new_app.apk'."
}

# Function to sign APK
sign_apk() {
    echo "Signing APK..."
    if [ ! -f "$KEYSTORE_FILE" ]; then
        echo "Keystore file '$KEYSTORE_FILE' not found! Creating one..."
        keytool -genkey -v -keystore "$KEYSTORE_FILE" -keyalg RSA -keysize 2048 -validity 10000 -alias "$KEY_ALIAS" -storepass "$KEYSTORE_PASS" -keypass "$KEYSTORE_PASS"
    fi
    jarsigner -keystore "$KEYSTORE_FILE" -storepass "$KEYSTORE_PASS" -keypass "$KEYSTORE_PASS" new_app.apk "$KEY_ALIAS"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to sign APK!"
        exit 1
    fi
    echo "APK signed successfully!"
}

# Main script execution
install_dependencies
decompile_apk
change_package_name
rebuild_apk
sign_apk

echo "Done! The modified and signed APK is ready as 'new_app.apk'."
