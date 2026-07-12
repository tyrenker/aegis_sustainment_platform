# TODO (Phase 8, step 3): write the retrieval + generation logic yourself.
#
# Steps this needs to perform (see bible 1.9 for why each one matters):
#   1. embed the incoming question
#   2. query the Chroma collection from ingest.py for the top-k closest chunks
#   3. assemble a prompt: system prompt + retrieved chunks + question
#   4. call your locally-hosted model with that prompt
#   5. return the response
#
# Package this as a container using ./Dockerfile once it works, and deploy it as the pod defined
# in ../k8s/ai-assistant/deployment.yaml.

import chromadb
from sentence_transformers import SentenceTransformer

model = SentenceTransformer("all-MiniLM-L6-v2")
client = chromadb.PersistentClient(path="./chroma_db")
collection = client.get_or_create_collection("logistics_docs")


def answer(question: str) -> str:
    # TODO: embed the question
    # TODO: query collection for top-k chunks
    # TODO: assemble prompt (system prompt + chunks + question)
    # TODO: call your local model, return its response
    raise NotImplementedError


if __name__ == "__main__":
    # TODO: simple CLI loop, or wrap `answer()` in a small FastAPI app — your choice
    pass
