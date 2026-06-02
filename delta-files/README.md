# **Delta File Downloader Script**

## **Overview**

This bash script is designed to automate the downloading of delta files from an API endpoint. It provides a robust solution for incrementally retrieving files based on the last downloaded file, with built-in error handling and validation.

## **Purpose**

The script serves as a utility for:

* Downloading delta (incremental) files from a specified API  
* Managing file downloads in a designated directory  
* Handling authentication and pagination of file downloads  
* Providing detailed logging of download processes

## **Prerequisites**

Before using the script, ensure you have the following:

* Bash shell environment  
* `curl` installed for making HTTP requests  
* `jq` installed for JSON processing  
* Valid Personal Access Token (PAT) for API authentication

### **Required Dependencies**

* bash  
* curl  
* jq

## **Usage**

```
./delta-file-downloader.sh <pat> <api_url> <download_path> <tenant_locator> <table_name> [delta_file_type]
```

### **Parameters**

1. `pat`: Personal Access Token for API authentication  
2. `api_url`: Base URL of the API endpoint  
3. `download_path`: Local directory to save downloaded files  
4. `tenant_locator`: Tenant identifier for the API request  
5. `table_name`: Name of the transformation table  
6. `delta_file_type`: *(Optional)* File type to download — `sql` or `csv`. Defaults to `csv`.

### **Example**

```
./delta-file-downloader.sh my_access_token https://api.example.com /home/user/downloads tenant_abc customers_table csv
```

## **Script Workflow**

1. **Input Validation**

   * Checks for minimum required arguments  
   * Validates the download path, creating it if it doesn't exist  
2. **File Discovery**

   * Lists existing files in the download directory  
   * Identifies the last downloaded file for incremental retrieval  
3. **API Interaction**

   * Calls the delta files listing endpoint  
   * Retrieves a list of files to download  
   * Handles cases with no available files  
4. **File Download**

   * Iterates through available delta files  
   * Downloads each file to the specified directory  
   * Provides HTTP status code verification  
   * Logs download successes and failures

## **Error Handling**

The script includes robust error handling:

* Exits with an error code if insufficient arguments are provided  
* Handles missing or null file names  
* Checks HTTP response codes during file download  
* Provides informative error messages

## **Logging**

The script generates console logs detailing:

* Folder creation/existence  
* Last downloaded file  
* API request details  
* Download status for each file  
* Overall script execution status

