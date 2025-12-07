Order Service: subscribes to product events via Dapr.

Endpoints:
- GET /dapr/subscribe (subscription declaration)
- POST /events/product (event handler)
- GET /healthz

Env:
- PUBSUB_NAME (default sns-pubsub) if later parameterized.
