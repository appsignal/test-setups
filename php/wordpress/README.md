# WordPress

A minimal WordPress site, based on the official `wordpress:php8.4-apache`
Docker image. It stores its data in an SQLite file inside the container,
using the official SQLite Database Integration plugin, so it needs no database
container. The data is lost when the container is removed.

WordPress is installed automatically on boot. Log in on
<http://localhost:4001/wp-admin> with user `admin` and password `password`.

The `app/mu-plugins` directory is loaded by WordPress as "must-use" plugins.
It adds three test pages, linked from the top of the homepage:

- `/slow` - a request that takes three seconds
- `/error` - a request that raises an error
- `/logs` - a request that writes a log line

It also raises an error when the "Error post" post is viewed on `/error-post`.
That post is created on boot.
