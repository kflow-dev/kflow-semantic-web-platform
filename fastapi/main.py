from fastapi import FastAPI
from fastapi.responses import PlainTextResponse
app = FastAPI()

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/")
def root():
    return {"status": "AI service running"}

@app.get("/metrics", response_class=PlainTextResponse)
def metrics():
    return "fastapi_service_up 1\n"
