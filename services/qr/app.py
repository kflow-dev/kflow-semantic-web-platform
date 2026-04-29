from fastapi import FastAPI
import qrcode, uuid

app = FastAPI()

@app.post("/generate")
def generate(entity_id: str):
    token = str(uuid.uuid4())
    url = f"http://localhost:7000/track/{token}"
    img = qrcode.make(url)
    path = f"/tmp/{token}.png"
    img.save(path)
    return {"url": url, "file": path}

@app.get("/track/{token}")
def track(token: str):
    return {"token": token, "status": "ok"}
