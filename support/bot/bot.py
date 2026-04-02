import os
import random
import time
from urllib.parse import urljoin

import requests
from bs4 import BeautifulSoup

APP_URL = os.environ.get("APP_URL", "http://app:4001")
INTERVAL = int(os.environ.get("BOT_INTERVAL", "5"))
MAX_RETRIES = 1200


def wait_for_app():
    for attempt in range(MAX_RETRIES):
        try:
            response = requests.get(APP_URL, timeout=1)
            if response.status_code == 200:
                print(f"App is ready at {APP_URL}")
                return
            reason = f"status {response.status_code}"
        except requests.RequestException as e:
            reason = str(e)

        if attempt % 5 == 0:
            print(f"Waiting for app... ({attempt}/{MAX_RETRIES}) {reason}")
        time.sleep(1)

    print(f"App did not become ready after {MAX_RETRIES} retries. Exiting.")
    raise SystemExit(1)


def find_links(html):
    soup = BeautifulSoup(html, "html.parser")
    links = []
    for a in soup.find_all("a", href=True):
        href = a["href"]
        if href.startswith(("http://", "https://")):
            if not href.startswith(APP_URL):
                continue
        if href.startswith("#"):
            continue
        links.append(urljoin(APP_URL, href))
    return links


def run():
    wait_for_app()

    while True:
        try:
            response = requests.get(APP_URL, timeout=10)
            links = find_links(response.text)

            if not links:
                print(f"No links found on index page, retrying in {INTERVAL}s")
            else:
                link = random.choice(links)
                try:
                    r = requests.get(link, timeout=10)
                    print(f"GET {link} -> {r.status_code}")
                except requests.RequestException as e:
                    print(f"GET {link} -> error: {e}")
        except requests.RequestException as e:
            print(f"Failed to fetch index: {e}")

        time.sleep(INTERVAL)


if __name__ == "__main__":
    run()
