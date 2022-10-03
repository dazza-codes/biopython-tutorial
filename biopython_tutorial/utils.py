from pathlib import Path

import requests


def download_file(url, overwrite: bool = False) -> Path:
    local_filename = url.split('/')[-1]
    local_path = Path(local_filename)
    if local_path.exists():
        if not overwrite:
            return local_path

    with requests.get(url, stream=True) as r:
        r.raise_for_status()
        with open(local_filename, 'wb') as f:
            for chunk in r.iter_content(chunk_size=8192):
                f.write(chunk)

    return local_path
