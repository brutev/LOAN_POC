import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_form_metadata_pre_sanction():
    context = {
        "stage": "PRE_SANCTION",
        "version": "WORKING_V1",
        "values": {"CUST_LOAN_AMOUNT": 1200000}
    }
    resp = client.post("/form-metadata", json=context)
    assert resp.status_code == 200
    data = resp.json()
    # PAN should be mandatory due to dependency
    pan_field = next(f for c in data["cards"] for f in c["fields"] if f["fieldId"] == "CUST_PAN")
    assert pan_field["mandatory"] is True
    # Fields should be editable
    assert pan_field["editable"] is True
    # Tile should be incomplete if PAN missing
    assert data["completionStatus"] == "INCOMPLETE"
    assert "prerequisiteIncompleteReason" in data

def test_form_metadata_post_sanction():
    context = {
        "stage": "POST_SANCTION",
        "version": "WORKING_V2",
        "values": {"CUST_LOAN_AMOUNT": 1200000}
    }
    resp = client.post("/form-metadata", json=context)
    assert resp.status_code == 200
    data = resp.json()
    # All fields should be frozen
    for c in data["cards"]:
        for f in c["fields"]:
            assert f["editable"] is False
            assert f["freezeReason"] == "SANCTION_APPROVED"
    # Diff logic: changedFields present
    assert "changedFields" in data
    assert "CUST_LOAN_AMOUNT" in data["changedFields"]
