## Vector + MongoDB test setup

This test setup launches a MongoDB cluster and several instances of a small Ruby application that creates, reads, updates and deletes documents in that cluster. This allows testing of the MongoDB automated dashboard.

To use this test setup, you must first add an **app-level** push API key to `appsignal_key.env` as follows:

```
APPSIGNAL_VECTOR_APP_PUSH_API_KEY=...
```
