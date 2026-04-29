from fastapi import FastAPI
from llama_index.core import VectorStoreIndex, SimpleDirectoryReader

app = FastAPI()

docs = SimpleDirectoryReader("./data").load_data()
index = VectorStoreIndex.from_documents(docs)

@app.get("/query")
def query(q: str):
    return {"response": str(index.as_query_engine().query(q))}

