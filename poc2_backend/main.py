from fastapi import FastAPI, Body
from typing import Any, Dict
from models.context import Context
from services.metadata_service import get_final_form_metadata
import logging
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Allow all origins for development; restrict in production as needed
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

logging.basicConfig(level=logging.INFO)

@app.post("/form-metadata")
def form_metadata(context: Context = Body(...)) -> Dict[str, Any]:
    """
    Returns fully evaluated, render-ready form metadata for the given context.
    """
    logging.info(f"Received context: {context.model_dump()}")
    return get_final_form_metadata(context)
