# POC-2 Backend (FastAPI)

This backend produces fully evaluated, render-ready metadata for dynamic forms, supporting dependencies, prerequisites, freeze, revert, and changed-field highlighting. Flutter consumes this API with no code changes required for new logic.

## Features
- Field registry (immutable IDs)
- Base form template (tiles → cards → fields)
- Context model (stage, version, values)
- Dependency evaluation (e.g., PAN mandatory if loan > 10L)
- Tile prerequisite evaluation (locks, reasons)
- Freeze logic (post-sanction)
- Revert/diff logic (changed fields)
- Metadata assembly (no raw rules)
- End-to-end tests

## Usage
- Install dependencies: `pip install poetry && poetry install`
- Run API: `poetry run uvicorn main:app --reload`
- Run tests: `poetry run pytest`

## API
- `POST /form-metadata` — Returns evaluated form metadata for given context

## Example context
```
{
  "stage": "PRE_SANCTION",
  "version": "WORKING_V1",
  "values": {"CUST_LOAN_AMOUNT": 1200000}
}
```
