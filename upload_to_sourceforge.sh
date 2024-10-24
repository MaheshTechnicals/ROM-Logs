#!/bin/bash

# Read credentials from private.json
credentials_file="private.json"

if [ ! -f "$credentials_file" ]; then
  echo "Error: Credentials file '$credentials_file' not found!"
  exit 1
fi

username=$(jq -r '.username' $credentials_file)
password=$(jq -r '.password' $credentials_file)
project=$(jq -r '.project' $credentials_file)
upload_path=$(jq -r '.upload_path' $credentials_file)

# Check if jq command exists
if ! command -v jq &> /dev/null
then
    echo "Error: jq is not installed. Please install jq to parse JSON."
    exit 1
fi

# Ensure all credentials are set
if [ -z "$username" ] || [ -z "$password" ] || [ -z "$project" ] || [ -z "$upload_path" ]; then
  echo "Error: Missing credentials in 'private.json'!"
  exit 1
fi

# Find .img and .zip files in the current directory
files_to_upload=$(find . -type f \( -name "*.img" -o -name "*.zip" \))

if [ -z "$files_to_upload" ]; then
  echo "No .img or .zip files found to upload."
  exit 0
fi

# Upload each file to SourceForge using scp
for file in $files_to_upload; do
  echo "Uploading $file to SourceForge..."
  scp "$file" "$username,$project@frs.sourceforge.net:/home/frs/project/$upload_path" || {
    echo "Error: Failed to upload $file"
    exit 1
  }
done

echo "All files uploaded successfully!"
