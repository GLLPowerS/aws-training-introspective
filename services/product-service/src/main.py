import os
from typing import Any, Dict

import httpx
from fastapi import FastAPI, HTTPException

app = FastAPI(title="Product Service")

DAPR_HTTP_PORT = os.getenv("DAPR_HTTP_PORT", "3500")
PUBSUB_NAME = os.getenv("DAPR_PUBSUB_NAME", "sns-pubsub")
TOPIC = os.getenv("DAPR_PUBSUB_TOPIC", "product-events")
DAPR_BASE_URL = f"http://127.0.0.1:{DAPR_HTTP_PORT}/v1.0"


@app.get("/healthz")
async def health() -> Dict[str, str]:
    return {"status": "ok"}


@app.post("/products")
async def publish_product(payload: Dict[str, Any]) -> Dict[str, str]:
    publish_url = f"{DAPR_BASE_URL}/publish/{PUBSUB_NAME}/{TOPIC}"
    async with httpx.AsyncClient() as client:
        resp = await client.post(publish_url, json=payload)
        if resp.is_error:
            raise HTTPException(status_code=resp.status_code, detail=resp.text)
    return {"status": "published"}
