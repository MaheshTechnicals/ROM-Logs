import os
import requests
from urllib.parse import urlparse, unquote

def download_file(url, save_path):
    with requests.get(url, stream=True) as response:
        response.raise_for_status()
        with open(save_path, 'wb') as file:
            for chunk in response.iter_content(chunk_size=8192):
                file.write(chunk)
    print(f"Downloaded {os.path.basename(save_path)}")


def download_terabox_folder(folder_url):
    response = requests.get(folder_url)
    if response.status_code != 200:
        print("Failed to access the folder URL.")
        return

    # Extract file links from the folder page
    file_links = extract_file_links(response.text)
    if not file_links:
        print("No files found in the folder.")
        return

    # Create a directory to save the downloaded files
    folder_name = urlparse(folder_url).path.split('/')[-1]
    os.makedirs(folder_name, exist_ok=True)

    for file_link in file_links:
        file_name = unquote(urlparse(file_link).path.split('/')[-1])
        save_path = os.path.join(folder_name, file_name)
        download_file(file_link, save_path)


def extract_file_links(html_content):
    # Implement this function to extract file links from the HTML content
    # You may use BeautifulSoup or regex to parse the HTML
    file_links = []  # Populate this list with extracted file links
    return file_links


if __name__ == "__main__":
    folder_url = input("Enter the TeraBox folder URL: ")
    download_terabox_folder(folder_url)
