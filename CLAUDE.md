# Test applications

## Project Structure

Each directory in this repository contains example applications for a different programming language or environment, with the exception of the 'support' and 'test' directories.
In each directory, each subdirectory contains a different example application.

- /<language> - Example and application directories for each language, e.g. `/ruby`, `/nodejs`, `/java`, etc.
  - /app - The directory containing the application code.
    - This directory is mounted on the container.
  - /commands - Commands that can be run in the container
    - The `run` script is run by the container on boot.
      It contains the commands to start the application in the container itself.
- /support - Additional support files for the test applications
- /test - Test files

## Starting Applications

You can start each application by running the following command and replacing the `<app_name>` value with the test applications directory name, e.g. `ruby/hanami2`.

```bash
rake app=<app_name> app:down app:up
```

Only one application can be running at time, because they all bind to the same port: `4001`

## Running Automated Tests

You can run each application's test suite by running the following command and replacing the `<app_name>` value with the test applications directory name, e.g. `ruby/hanami2`.

```bash
rake app=<app_name> app:test
```

If you see a lot of these messages that means it's running into an issue on boot and won't start.
Exit the application and try something else.

> The app has not started yet. Retrying... (<retry time in seconds>/<maximum retry time in seconds>)
