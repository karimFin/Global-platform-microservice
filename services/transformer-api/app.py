import os

import torch
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from transformers import AutoModelForSequenceClassification, AutoTokenizer

app = FastAPI()
service = os.getenv("SERVICE_NAME", "transformer-api")
model_dir = os.getenv("MODEL_DIR", "./model")
base_model = os.getenv("BASE_MODEL", "distilbert-base-uncased-finetuned-sst-2-english")
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
tokenizer = None
model = None
model_error = None


def load_model():
    path = model_dir if os.path.isdir(model_dir) else base_model
    tokenizer = AutoTokenizer.from_pretrained(path)
    model = AutoModelForSequenceClassification.from_pretrained(path)
    model.to(device)
    model.eval()
    return tokenizer, model


def ensure_model_loaded():
    global tokenizer, model, model_error
    if tokenizer is not None and model is not None:
        return
    if model_error is not None:
        raise model_error
    try:
        tokenizer, model = load_model()
    except Exception as exc:
        model_error = exc
        raise


class InferRequest(BaseModel):
    text: str


class BatchInferRequest(BaseModel):
    texts: list[str]


def format_labels(score_row):
    id2label = model.config.id2label or {}
    if isinstance(id2label, dict) and id2label:
        labels = [id2label.get(i, str(i)) for i in range(len(score_row))]
    else:
        labels = [str(i) for i in range(len(score_row))]
    scores = {labels[i]: score_row[i] for i in range(len(score_row))}
    best_idx = max(range(len(score_row)), key=lambda i: score_row[i])
    return {"label": labels[best_idx], "score": score_row[best_idx], "scores": scores}


def predict(texts):
    ensure_model_loaded()
    inputs = tokenizer(texts, return_tensors="pt", padding=True, truncation=True)
    inputs = {k: v.to(device) for k, v in inputs.items()}
    with torch.no_grad():
        outputs = model(**inputs)
        probs = torch.softmax(outputs.logits, dim=-1).cpu().tolist()
    return [format_labels(row) for row in probs]


@app.get("/")
def root():
    return {"service": service, "status": "running"}


@app.get("/health")
def health():
    return {"status": "ok", "service": service}


@app.get("/ready")
def ready():
    ready_status = tokenizer is not None and model is not None
    return {"status": "ready" if ready_status else "loading", "service": service}


@app.get("/startup")
def startup():
    return {"status": "started", "service": service}


@app.get("/ping")
def ping():
    return {"service": service, "pong": True}


@app.post("/infer")
def infer(payload: InferRequest):
    try:
        results = predict([payload.text])
    except Exception as exc:
        raise HTTPException(status_code=503, detail=str(exc))
    return {"service": service, "results": results}


@app.post("/infer/batch")
def infer_batch(payload: BatchInferRequest):
    try:
        results = predict(payload.texts)
    except Exception as exc:
        raise HTTPException(status_code=503, detail=str(exc))
    return {"service": service, "results": results}
