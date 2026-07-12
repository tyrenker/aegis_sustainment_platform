# TODO (Phase 8, step 2): write the ingestion logic yourself.
#
# After writing it, print the retrieved chunks for a real query and read them before moving on —
# confirm retrieval is actually returning relevant content, don't just assume it works because it
# ran without an error.

from sentence_transformers import SentenceTransformer
import chromadb

model = SentenceTransformer("all-MiniLM-L6-v2")
client = chromadb.PersistentClient(path="./chroma_db")
collection = client.get_or_create_collection("logistics_docs")


def ingest(file_path: str):
    # TODO: read the file
    # TODO: split into chunks (your logic — think about chunk size and overlap)
    # TODO: embed the chunks with `model.encode(...)`
    # TODO: collection.add(documents=..., embeddings=..., ids=...)
    raise NotImplementedError


if __name__ == "__main__":
    # TODO: loop over your corpus/ directory and call ingest() on each file
    pass
