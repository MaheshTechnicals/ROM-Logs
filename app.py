import os
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, unquote

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
    file_links = extract_file_links(response.text, folder_url)
    if not file_links:
        print("No files found in the folder.")
        return

    # Create a directory to save the downloaded files
    folder_name = folder_url.split('/')[-1]
    os.makedirs(folder_name, exist_ok=True)

    for file_link in file_links:
        file_name = unquote(urljoin(folder_url, file_link).split('/')[-1])
        save_path = os.path.join(folder_name, file_name)
        download_file(urljoin(folder_url, file_link), save_path)

def extract_file_links(html_content, base_url):
    soup = BeautifulSoup(html_content, 'html.parser')
    file_links = []

    # Example: Find all anchor tags with a specific class or pattern
    # This pattern might need adjustments based on the TeraBox page structure
    for link in soup.find_all('a'):
        href = link.get('href')
        if href and href.endswith(('zip', 'rar', 'mp4', 'pdf', 'jpg', 'png')):  # Adjust extensions as needed
            file_links.append(href)

    return file_links

if __name__ == "__main__":
    folder_url = input("Enter the TeraBox folder URL: ")
    download_terabox_folder(folder_url)
