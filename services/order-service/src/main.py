import os
from typing import Any, Dict, List

from fastapi import FastAPI

app = FastAPI(title="Order Service")

TOPIC = os.getenv("DAPR_PUBSUB_TOPIC", "product-events")
PUBSUB_NAME = os.getenv("DAPR_PUBSUB_NAME", "redis-pubsub")


@app.get("/healthz")
async def health() -> Dict[str, str]:
    return {"status": "ok"}


@app.get("/dapr/subscribe")
async def dapr_subscribe() -> List[Dict[str, str]]:
    return [
        {
            "pubsubname": PUBSUB_NAME,
            "topic": TOPIC,
            "route": "/events/product",
        }
    ]


@app.post("/events/product")
async def handle_product_event(event: Dict[str, Any]) -> Dict[str, str]:
    print(f"Received product event: {event}")
    return {"status": "received", "event": "product"}
