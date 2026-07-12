# TODO (Phase 8): fill in a base image and the run command once app.py works locally.
# This packaging step is standard boilerplate, not a learning objective — feel free to reference
# any Python Dockerfile example for the shape.

FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

# TODO: CMD to run app.py (or your FastAPI app via uvicorn)
