# README

## Installation

```
bundle install
yarn
```

## Usage

First, change the revision in `config/appsignal.yml` if you want to test new
sourcemaps.

Create assets and upload sourcemaps:

```
bin/rails sourcemaps
```

Start rails:

```
bin/rails s -e production
```
