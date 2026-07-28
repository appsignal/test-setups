import os
import random
import time
from collections import OrderedDict
from urllib.parse import urldefrag, urljoin, urlparse

import requests
from bs4 import BeautifulSoup

APP_URL = os.environ.get("APP_URL", "http://app:4001")
APP_HOST = urlparse(APP_URL).netloc.lower()
INTERVAL = int(os.environ.get("BOT_INTERVAL", "5"))
# How many links the bot follows away from the root page before it starts over
# from the root page again. Some interesting routes are not linked from the root
# page, so the bot has to walk deeper to reach them. Set to 1 to only ever
# request pages that the root page links to.
MAX_DEPTH = int(os.environ.get("BOT_MAX_DEPTH", "5"))
# How many pages the bot remembers requesting. Once the memory is full, the
# pages it requested longest ago are forgotten and become new to it again.
MEMORY_SIZE = int(os.environ.get("BOT_MEMORY_SIZE", "1000"))
MAX_REDIRECTS = 5
MAX_RETRIES = 1200

# Requesting these produces no traces worth looking at, and they link nowhere,
# so following one only ends the walk early.
ASSET_SUFFIXES = (
    ".css",
    ".eot",
    ".gif",
    ".ico",
    ".jpeg",
    ".jpg",
    ".js",
    ".map",
    ".png",
    ".svg",
    ".ttf",
    ".webp",
    ".woff",
    ".woff2",
)


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


# The bot must only ever request the app it was pointed at. Pages that are not
# part of the app link elsewhere: a Rails error page links to the Rails guides,
# for example. Comparing the host is what keeps the bot in the app, and it has
# to be the whole host, because a prefix comparison against APP_URL would also
# accept a host like `app:4001.example.com`.
def on_app_host(url):
    parsed = urlparse(url)
    # Hosts are case-insensitive, so a link to `HTTP://APP:4001/` is on the
    # app's host and must not be skipped.
    return parsed.scheme in ("http", "https") and parsed.netloc.lower() == APP_HOST


def is_asset(url):
    return urlparse(url).path.lower().endswith(ASSET_SUFFIXES)


def find_links(page_url, html):
    soup = BeautifulSoup(html, "html.parser")
    # Two links on a page can point at the same URL, which would give that URL a
    # better chance of being picked than the others. Keep one of each.
    links = OrderedDict()
    for a in soup.find_all("a", href=True):
        href = a["href"]
        if href.startswith("#"):
            continue
        # Relative links resolve against the page they were found on, which is
        # not the root page once the bot walks deeper.
        link, _fragment = urldefrag(urljoin(page_url, href))
        if not on_app_host(link):
            continue
        if is_asset(link):
            continue
        links[link] = None
    return list(links)


# Requests the page and returns the links on it, along with every URL it
# requested to get there. Redirects are followed one at a time, rather than by
# `requests` itself, so that a redirect leading off the app can be refused
# before it is requested.
def fetch(url, depth):
    requested = []

    # One more request than the redirects allowed, because the page the last
    # redirect leads to still has to be requested.
    for _hop in range(MAX_REDIRECTS + 1):
        requested.append(url)

        try:
            response = requests.get(url, timeout=10, allow_redirects=False)
        except requests.RequestException as e:
            print(f"GET {url} -> error: {e}")
            return [], requested

        print(f"GET {url} -> {response.status_code} (depth {depth})")

        if not response.is_redirect:
            if not response.headers.get("content-type", "").startswith("text/html"):
                return [], requested
            return find_links(url, response.text), requested

        target = urljoin(url, response.headers.get("location", ""))
        if not on_app_host(target):
            print(f"Not following redirect to {target}, it leaves {APP_HOST}")
            return [], requested

        url = target

    print(f"Giving up on {url}, it redirected more than {MAX_REDIRECTS} times")
    return [], requested


def remember(seen, url, step):
    seen[url] = step
    seen.move_to_end(url)
    while len(seen) > MEMORY_SIZE:
        seen.popitem(last=False)


def pick_next(seen, links):
    # Go to whichever page the bot has gone the longest without requesting, so
    # it covers the whole app before it requests any page a second time. A page
    # it has never requested wins, because -1 comes before every step number.
    # Ties are broken at random, which is what keeps the walks varied.
    oldest = min(seen.get(link, -1) for link in links)
    return random.choice([link for link in links if seen.get(link, -1) == oldest])


def run():
    wait_for_app()

    url = APP_URL
    depth = 0
    step = 0
    # Kept across walks, not per walk, so a new walk does not repeat the pages
    # the last one just requested.
    seen = OrderedDict()
    walked = set()

    while True:
        links, requested = fetch(url, depth)

        for requested_url in requested:
            remember(seen, requested_url, step)
            step += 1
            walked.add(requested_url)

        # A walk only ever goes somewhere it has not been yet. Two pages that
        # link to each other would otherwise make it bounce between the two for
        # the rest of its hops.
        candidates = [link for link in links if link not in walked]

        if candidates and depth < MAX_DEPTH:
            url = pick_next(seen, candidates)
            depth += 1
        else:
            # Nowhere new to go, or deep enough. Start a new walk from the root
            # page, which can then take a different path through the app.
            url = APP_URL
            depth = 0
            walked = set()

        time.sleep(INTERVAL)


if __name__ == "__main__":
    run()
