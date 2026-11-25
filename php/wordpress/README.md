# WordPress

A minimal WordPress site, based on the official `wordpress:php8.4-apache`
Docker image. It stores its data in an SQLite file inside the container,
using the official SQLite Database Integration plugin, so it needs no database
container. The data is lost when the container is removed.

WordPress is installed automatically on boot. Log in on
<http://localhost:4001/wp-admin> with user `admin` and password `password`.

The `app/mu-plugins` directory is loaded by WordPress as "must-use" plugins.
It adds two test pages, linked from the top of the homepage:

- `/slow` - a request that takes three seconds
- `/error` - a request that writes log lines with `error_log()` and
  `trigger_error()`, then raises an error

It also writes the same log lines and raises an error when the "Error post"
post is viewed on `/error-post`.
That post is created on boot.

The MC4WP ("Mailchimp for WordPress") plugin adds a newsletter signup form on
`/newsletter`, linked from the homepage. It needs a Mailchimp API key in a
`mailchimp.env` file in the root of this repository:

```
MAILCHIMP_API_KEY=<key>
```

The form subscribes to the first audience of that Mailchimp account. Without
the key, the app still starts, but the form isn't set up.
