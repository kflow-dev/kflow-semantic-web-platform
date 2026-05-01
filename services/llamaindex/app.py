import hashlib
import json
import math
import os
import re
from pathlib import Path
from typing import Any
from uuid import uuid5, NAMESPACE_URL

import requests
from fastapi import FastAPI
from fastapi.responses import PlainTextResponse
from pydantic import BaseModel
from qdrant_client import QdrantClient
from qdrant_client.http import models


app = FastAPI(title="KFlow RAG API")
INDEX_DIR = Path(os.getenv("RAG_DATA_DIR", "./data/indexed"))
RAW_DIR = Path(os.getenv("RAG_RAW_DIR", "./data/raw"))
COLLECTION = os.getenv("RAG_COLLECTION", "kflow_documents")
VECTOR_SIZE = int(os.getenv("RAG_VECTOR_SIZE", "384"))
QDRANT_URL = os.getenv("QDRANT_URL", "http://qdrant:6333")
OLLAMA_URL = os.getenv("OLLAMA_URL", "").rstrip("/")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "phi3:mini")

DOCUMENTS_TOTAL = 0
CHUNKS_TOTAL = 0
QUERIES_TOTAL = 0
CHATS_TOTAL = 0


class IngestRequest(BaseModel):
    name: str
    content: str
    source_type: str = "cms"
    metadata: dict[str, Any] = {}


class ChatRequest(BaseModel):
    message: str
    top_k: int = 5


def qdrant() -> QdrantClient:
    return QdrantClient(url=QDRANT_URL, timeout=10)


def ensure_collection() -> None:
    client = qdrant()
    collections = {item.name for item in client.get_collections().collections}
    if COLLECTION not in collections:
        client.create_collection(
            collection_name=COLLECTION,
            vectors_config=models.VectorParams(size=VECTOR_SIZE, distance=models.Distance.COSINE),
        )


def tokenize(text: str) -> list[str]:
    return re.findall(r"[a-zA-Z0-9_]+", text.lower())


def embed(text: str) -> list[float]:
    vector = [0.0] * VECTOR_SIZE
    for token in tokenize(text):
        digest = hashlib.sha256(token.encode("utf-8")).digest()
        index = int.from_bytes(digest[:4], "big") % VECTOR_SIZE
        sign = 1.0 if digest[4] % 2 == 0 else -1.0
        vector[index] += sign
    norm = math.sqrt(sum(value * value for value in vector)) or 1.0
    return [value / norm for value in vector]


def chunk_text(text: str, size: int = 900, overlap: int = 120) -> list[str]:
    clean = re.sub(r"\s+", " ", text).strip()
    if not clean:
        return []
    chunks = []
    start = 0
    while start < len(clean):
        chunks.append(clean[start:start + size])
        start += size - overlap
    return chunks


def safe_name(name: str) -> str:
    cleaned = "".join(char for char in name if char.isalnum() or char in ("-", "_", ".")).strip(".")
    return cleaned or "document.txt"


def readable_content(path: Path) -> str:
    text_extensions = {".txt", ".md", ".csv", ".json", ".html", ".htm", ".xml", ".ttl", ".rdf"}
    if path.suffix.lower() in text_extensions:
        return path.read_text(encoding="utf-8", errors="ignore")
    return f"Media asset {path.name} type={path.suffix.lower() or 'unknown'} size_bytes={path.stat().st_size}"


def upsert_document(name: str, content: str, source_type: str, metadata: dict[str, Any]) -> dict[str, int]:
    global DOCUMENTS_TOTAL, CHUNKS_TOTAL
    ensure_collection()
    INDEX_DIR.mkdir(parents=True, exist_ok=True)
    points = []
    chunks = chunk_text(content)
    for idx, chunk in enumerate(chunks):
        point_id = str(uuid5(NAMESPACE_URL, f"{source_type}:{name}:{idx}"))
        payload = {
            "name": name,
            "source_type": source_type,
            "chunk_index": idx,
            "text": chunk,
            "metadata": metadata,
        }
        points.append(models.PointStruct(id=point_id, vector=embed(chunk), payload=payload))
    if points:
        qdrant().upsert(collection_name=COLLECTION, points=points)
    (INDEX_DIR / f"{safe_name(name)}.json").write_text(
        json.dumps({"name": name, "source_type": source_type, "metadata": metadata}, indent=2),
        encoding="utf-8",
    )
    DOCUMENTS_TOTAL += 1
    CHUNKS_TOTAL += len(points)
    return {"documents": 1, "chunks": len(points)}


@app.get("/health")
def health():
    return {
        "status": "ok",
        "raw_dir": str(RAW_DIR),
        "collection": COLLECTION,
        "ollama_enabled": bool(OLLAMA_URL),
    }


@app.get("/metrics", response_class=PlainTextResponse)
def metrics():
    return "\n".join([
        f"rag_documents_total {DOCUMENTS_TOTAL}",
        f"rag_chunks_total {CHUNKS_TOTAL}",
        f"rag_queries_total {QUERIES_TOTAL}",
        f"rag_chats_total {CHATS_TOTAL}",
        "rag_service_up 1",
        "",
    ])


@app.post("/ingest")
def ingest(payload: IngestRequest):
    result = upsert_document(payload.name, payload.content, payload.source_type, payload.metadata)
    return {"status": "ok", **result}


@app.post("/index/raw")
def index_raw():
    indexed = {"documents": 0, "chunks": 0}
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    for path in RAW_DIR.rglob("*"):
        if path.is_file():
            result = upsert_document(
                name=str(path.relative_to(RAW_DIR)),
                content=readable_content(path),
                source_type="raw",
                metadata={"path": str(path), "extension": path.suffix.lower()},
            )
            indexed["documents"] += result["documents"]
            indexed["chunks"] += result["chunks"]
    return {"status": "ok", **indexed}


@app.get("/query")
def query(q: str, top_k: int = 5):
    global QUERIES_TOTAL
    QUERIES_TOTAL += 1
    ensure_collection()
    results = qdrant().search(collection_name=COLLECTION, query_vector=embed(q), limit=top_k)
    matches = [{"score": item.score, **item.payload} for item in results]
    response = matches[0]["text"] if matches else "No matching indexed content was found."
    return {"query": q, "matches": matches, "response": response}


@app.post("/chat")
def chat(payload: ChatRequest):
    global CHATS_TOTAL
    CHATS_TOTAL += 1
    retrieved = query(payload.message, payload.top_k)
    context = "\n\n".join(match["text"] for match in retrieved["matches"])
    if OLLAMA_URL:
        answer = requests.post(
            f"{OLLAMA_URL}/api/generate",
            json={
                "model": OLLAMA_MODEL,
                "stream": False,
                "prompt": f"Use this context to answer concisely:\n{context}\n\nQuestion: {payload.message}",
            },
            timeout=60,
        ).json().get("response", "")
    else:
        answer = f"Retrieved {len(retrieved['matches'])} context chunks. {retrieved['response']}"
    return {"message": payload.message, "answer": answer, "context": retrieved["matches"]}
