# Install required libraries
!apt-get install python3-libtorrent -y
!pip install google-colab

import libtorrent as lt
import time
import datetime
import google.colab.drive as drive
import os

# Mount Google Drive
drive.mount('/content/drive')

# Change directory to a specific folder in Google Drive (optional)
save_path = '/content/drive/My Drive/TorrentDownloads'
os.makedirs(save_path, exist_ok=True)

# Ask the user for the magnet link
magnet_link = input("Please enter the magnet link: ")

# Initialize session and add magnet link
session = lt.session()
params = {
    'save_path': save_path,
    'storage_mode': lt.storage_mode_t(2),
    'paused': False,
    'auto_managed': True,
    'duplicate_is_error': True
}

handle = lt.add_magnet_uri(session, magnet_link, params)

print(f'Downloading Metadata for Torrent: {handle.name()}...')
while not handle.has_metadata():
    time.sleep(1)

print(f'Starting Torrent Download: {handle.name()}...')
print()

# Display download progress
while not handle.is_seed():
    s = handle.status()
    state_str = ['queued', 'checking', 'downloading metadata', 'downloading', 'finished', 'seeding', 'allocating', 'checking fastresume']
    
    print(f'\rDownload Progress: {s.progress * 100:.2f}% | '
          f'State: {state_str[s.state]} | '
          f'Download Rate: {s.download_rate / 1000:.2f} kB/s | '
          f'Upload Rate: {s.upload_rate / 1000:.2f} kB/s | '
          f'Peers: {s.num_peers} | '
          f'ETA: {str(datetime.timedelta(seconds=int(s.total_wanted_done / max(1, s.download_rate))))}',
          end=' ')
    
    time.sleep(1)

print("\n\nDownload Complete!")

# Save the download information to a file (optional)
with open(f'{save_path}/{handle.name()}.status', 'w') as f:
    f.write(f'Torrent Name: {handle.name()}\n')
    f.write(f'Completed: {datetime.datetime.now()}\n')
