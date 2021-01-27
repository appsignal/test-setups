# JavaScript + webpack test app

## Usage

Update the `app.env` to use your own Front-end API key.

Run `rake app=javascript/webpack app:up` to prepare the app environment and build the integration.
Run `rake app=javascript/webpack app:console` to run the webserver. Restart the command after updating the `REVISION` file to submit the sourcemaps for the new revision.

Visit `https://localhost:4001` on the host machine to load the app in the
browser and send a demo and custom error.
