#!/bin/bash

# Variables
KEYSTORE_NAME="my-release-key.jks"
KEY_ALIAS="my-key-alias"
KEYSTORE_PASS="changeit"
APKTOOL="apktool"
ZIPALIGN="zipalign"
JAVA_VERSION="11"
KEY_VALIDITY="10000"

# Check and install dependencies
install_dependencies() {
    echo "Checking and installing required tools..."

    # Update package list
    sudo apt update

    # Install OpenJDK if not installed
    if ! java -version 2>/dev/null | grep -q "openjdk version \"$JAVA_VERSION\""; then
        echo "Installing OpenJDK $JAVA_VERSION..."
        sudo apt install -y openjdk-$JAVA_VERSION-jdk
    else
        echo "OpenJDK $JAVA_VERSION is already installed."
    fi

    # Install apktool if not installed
    if ! command -v $APKTOOL &>/dev/null; then
        echo "Installing apktool..."
        sudo apt install -y apktool
    else
        echo "Apktool is already installed."
    fi

    # Install zipalign (part of Android SDK Build-Tools)
    if ! command -v $ZIPALIGN &>/dev/null; then
        echo "Installing zipalign..."
        sudo apt install -y zipalign
    else
        echo "Zipalign is already installed."
    fi

    echo "All dependencies are installed."
}

# Generate a keystore if it does not exist
generate_keystore() {
    if [ ! -f "$KEYSTORE_NAME" ]; then
        echo "Generating a keystore..."
        keytool -genkeypair -v -keystore $KEYSTORE_NAME -keyalg RSA -keysize 2048 -validity $KEY_VALIDITY \
            -storepass $KEYSTORE_PASS -keypass $KEYSTORE_PASS -alias $KEY_ALIAS \
            -dname "CN=Mahesh, OU=MaheshOS, O=MaheshOS, L=Random City, S=Random State, C=US"
        echo "Keystore generated and saved as $KEYSTORE_NAME."
    else
        echo "Keystore already exists. Using the existing keystore."
    fi
}

# Extract, modify package name, recompile, and sign APK
process_apk() {
    local INPUT_APK=$1
    local NEW_PACKAGE_NAME=$2
    local OUTPUT_APK="modified_$INPUT_APK"

    if [ -z "$INPUT_APK" ] || [ -z "$NEW_PACKAGE_NAME" ]; then
        echo "Usage: $0 <apk_file> <new_package_name>"
        exit 1
    fi

    if [ ! -f "$INPUT_APK" ]; then
        echo "Input APK file not found: $INPUT_APK"
        exit 1
    fi

    echo "Decompiling APK..."
    $APKTOOL d -f -o temp_apk "$INPUT_APK"

    echo "Modifying package name..."
    # Modify AndroidManifest.xml and other files
    sed -i "s/package=\"[^\"]*\"/package=\"$NEW_PACKAGE_NAME\"/g" temp_apk/AndroidManifest.xml

    # Replace package references in smali files
    find temp_apk/smali -type f -name "*.smali" -exec sed -i "s/$(echo $OLD_PACKAGE_NAME | sed 's/\./\\./g')/$NEW_PACKAGE_NAME/g" {} +

    echo "Recompiling APK..."
    $APKTOOL b temp_apk -o "$OUTPUT_APK"

    echo "Signing APK..."
    jarsigner -verbose -keystore $KEYSTORE_NAME -storepass $KEYSTORE_PASS -keypass $KEYSTORE_PASS \
        -sigalg SHA256withRSA -digestalg SHA-256 "$OUTPUT_APK" $KEY_ALIAS

    echo "Optimizing APK with zipalign..."
    zipalign -v 4 "$OUTPUT_APK" "signed_$OUTPUT_APK"

    echo "Cleaning up..."
    rm -rf temp_apk "$OUTPUT_APK"

    echo "Modified and signed APK saved as: signed_$OUTPUT_APK"
}

# Main script
main() {
    install_dependencies
    generate_keystore

    echo "Starting APK modification process..."
    process_apk "$@"
}

# Run the main function with all script arguments
main "$@"
