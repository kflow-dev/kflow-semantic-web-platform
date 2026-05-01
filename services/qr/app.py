from fastapi import FastAPI
from pydantic import BaseModel
import qrcode, uuid
import os

app = FastAPI()

class GenerateRequest(BaseModel):
    entity_id: str

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/generate")
def generate(payload: GenerateRequest):
    token = str(uuid.uuid4())
    public_url = os.getenv("PUBLIC_URL", "https://localhost").rstrip("/")
    url = f"{public_url}/qr/track/{token}"
    img = qrcode.make(url)
    path = f"/tmp/{token}.png"
    img.save(path)
    return {"entity_id": payload.entity_id, "token": token, "url": url, "file": path}

@app.get("/track/{token}")
def track(token: str):
    return {"token": token, "status": "ok"}
