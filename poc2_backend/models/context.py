from pydantic import BaseModel
from typing import Dict, Any

class Context(BaseModel):
    stage: str
    version: str
    values: Dict[str, Any] = {}
