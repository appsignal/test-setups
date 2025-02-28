# go-experiment

### Installation instructions

First of all, make sure that you have your GOPATH set up.

This app should be stored in:

`$GOPATH/src/github.com/appsignal/go-experiment`

To install dependencies:

`$ go get`

To run the app:

`$ go run main.go`

It'll start a web server in your `localhost:8080`

Available endpoints:

```
POST "/book"
GET "/books"
GET "/books{id}
PATCH "/books{id}
DELETE "/books{id}
GET "/redisquery"
GET "/mongoquery"

### Connecting with the standalone agent

Follow the instructions here: https://github.com/appsignal/integration-guide/wiki/OpenTelemetry-guide-for-new-languages#appsignal-agent
