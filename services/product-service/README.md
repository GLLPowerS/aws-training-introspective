Product Service: publishes product events to Dapr pub/sub.

Endpoints:
- POST /products (body forwarded to pubsub topic)
- GET /healthz

Env:
- DAPR_HTTP_PORT (default 3500)
- DAPR_PUBSUB_NAME (default sns-pubsub)
- DAPR_PUBSUB_TOPIC (default product-events)
