from utils.utils import *
from helpers.helpers import *

if __name__ == '__main__':
    
    # Ask the user for the TeraBox share link
    url = input('Enter TeraBox share link: ')
    
    # Shorten the URL if necessary
    short_url = get_short_url(url)
    pwd = ''

    # Get information about the shared folder or file
    info = get_info(short_url=short_url, pwd=pwd)
    items = getInfoItems(info=info) 

    # Write the information to JSON files
    write_json(info, 'info.json')
    write_json(items, 'items.json')

    # Extract necessary information for downloading
    shareid = info['shareid']
    uk = info['uk']
    sign = info['sign']
    timestamp = info['timestamp']

    # Check if the download directory exists, create if not
    check_path('downloads')

    # Initialize counters for progress tracking
    i, j = 1, len(items['items'])

    # Loop through each item to download
    for item in items['items']:
        fs_id = item['fs_id']
        file_name = item['file_name']
        file_path = item['file_path']
        download_dir = 'downloads' + item['dir_name']
        download_path = 'downloads' + file_path
        temp_path = download_path + '.aria2'

        # Remove temporary aria2 file if it exists
        if(path_exists(temp_path)):
            remove_file(temp_path)
            remove_file(download_path)

        # Check if the file has already been downloaded
        if(path_exists(download_path)):
            print(f'[{i}/{j}][exists] {file_name}')
        else:
            # Get the download URL and download the file
            dl_url = get_download(short_url=short_url, pwd=pwd, shareid=shareid, uk=uk, sign=sign, timestamp=timestamp, fs_id=fs_id)
            check_path(download_dir)
            download(dl_url, download_dir)
            print(f'[{i}/{j}][downloaded] {file_name}')
        
        # Increment the counter
        i += 1
