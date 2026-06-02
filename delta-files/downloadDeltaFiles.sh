#!/bin/bash

# Validate input arguments
if [ $# -lt 5 ]; then
    echo "Usage: $0 <pat> <api_url> <download_path> <tenant_locator> <table_name> [delta_file_type]"
    exit 1
fi

# Assign input parameters
pat="$1"
api_url="$2"
download_path="$3"
tenant_locator="$4"
table_name="$5"
delta_file_type="${6:-csv}"
is_done="false"

if [ "$delta_file_type" != "sql" ] && [ "$delta_file_type" != "csv" ]; then
    echo "Invalid delta_file_type '$delta_file_type'. Must be 'sql' or 'csv'."
    exit 1
fi

# Validate download path
if [ ! -d "$download_path" ]; then
    # If the folder does not exist, create it
    mkdir -p "$download_path"
    echo "Folder '$download_path' created."
else
    # If the folder exists, print a message
    echo "Folder '$download_path' exists."
fi

while [ "$is_done" != "true" ]; do
    # Get the list of files, sort them by time
    #sorted_files=$(ls -1 "$download_path" 2>/dev/null | sort)
    sorted_files=$(ls -ltr "$download_path" | grep '^-' | awk '{for (i=9; i<=NF; i++) printf $i " "; print ""}')


    # Check if there are no files
    if [ -z "$sorted_files" ]; then
        echo "No files found in the folder."
        last_downloaded_file=""
    else
        # Get the last file in the sorted list
        last_downloaded_file=$(echo "$sorted_files" | awk '{$1=$1; print}' | tail -n 1)
        echo "Last downloaded file: $last_downloaded_file"
    fi

    echo "Fetching data from API: $api_url/delta-files/delta-files/list"
    response=$(curl --silent --location "$api_url/delta-files/delta-files/list" \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer $pat" \
    --data "{
        \"transformationTable\": \"$table_name\",
        \"tenantLocator\": \"$tenant_locator\",
        \"lastFile\" : \"$last_downloaded_file\",
        \"deltaFileType\": \"$delta_file_type\"
    }")

    # Check if .deltaFiles exists and contains at least one item
    if ! echo "$response" | jq -e '.deltaFiles | length > 0' > /dev/null 2>&1; then
        echo "No files to download in '.deltaFiles'."
        is_done="true"
        exit 1
    else
        echo "Files found in '.deltaFiles'. Proceeding..."
    fi

    # Extract and process the 'deltaFiles' array
    echo "$response" | jq -c '.deltaFiles[]' | while IFS= read -r item; do
        echo "Processing item: $item"

        # Extract the file name
        file_name=$(echo "$item" | jq -r '.fileName')
        fileToDownload="${file_name##*/}"
        echo "File Name: $fileToDownload"

        # Handle missing or null file names
        if [ -z "$file_name" ] || [ "$file_name" = "null" ]; then
            echo "File name is missing or null."
            exit 1
        fi

        echo "Downloading file: $file_name"
        response_code=$(curl --silent -o "$download_path/$fileToDownload" -w "%{http_code}" "$api_url/delta-files/delta-files/download" \
        --header "Authorization: Bearer $pat" \
        --header "Content-Type: application/json" \
        --data "{\"fileName\": \"$file_name\", \"tenantLocator\": \"$tenant_locator\"}")

        # Check the HTTP status code
        if [ "$response_code" -eq 200 ]; then
            echo "File $file_name downloaded successfully."
        else
            echo "Failed to download file $file_name. HTTP status: $response_code"
            exit 1
        fi
    done
done
echo "Script execution completed successfully."
exit 0
