# Loan POC: Backend-Driven Dynamic Form (Flutter + FastAPI)

## Overview
This project demonstrates a fully backend-driven dynamic form system using Flutter (frontend) and FastAPI (Python backend). All form logic, validation, dependencies, and UI state are controlled by backend metadata. The Flutter app acts as a pure renderer.

## Features
- **Backend-driven UI:** No business logic in Flutter; all rules come from backend metadata.
- **Dynamic fields:** Required, editable, visible, and frozen fields are controlled by backend.
- **Dependency logic:** Example: PAN is required if Loan Amount > 10L.
- **Tile/card locking, revert, and versioning**
- **Changed field highlighting**
- **Validation and error messages**

## Project Structure
```
loan_poc/           # Flutter app (frontend)
poc2_backend/       # FastAPI backend (Python)
```

## How to Run

### 1. Start the Backend (FastAPI)
```sh
cd poc2_backend
poetry install  # or pip install -r requirements.txt
poetry run uvicorn main:app --reload
```

### 2. Run the Flutter App
```sh
cd loan_poc
flutter pub get
flutter run -d chrome  # or your preferred device
```

## API Contract
- **POST /form-metadata**
  - Request: `{ "stage": "PRE_SANCTION", "version": "WORKING_V1", "values": { ... } }`
  - Response: Form metadata (see backend code for details)

## Customization
- Change field logic in `poc2_backend/services/metadata_service.py`.
- UI improvements in `loan_poc/lib/screens/dynamic_form_screen.dart`.

## Authors
- Backend: Python FastAPI
- Frontend: Flutter

---
For questions or contributions, open an issue or pull request.
