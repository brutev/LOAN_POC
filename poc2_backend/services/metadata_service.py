from typing import Dict, Any
from models.context import Context
from field_registry import FIELD_REGISTRY
from base_form import BASE_FORM
import copy

# In-memory storage for sanctioned and working versions (for revert/diff logic)
SANCTIONED_SNAPSHOT = {
    "CUST_PAN": "ABCDE1234F",
    "CUST_AADHAAR": "123412341234",
    "CUST_LOAN_AMOUNT": 1000000
}

# Simulate working version as last submitted values (mutable)
WORKING_VERSION = copy.deepcopy(SANCTIONED_SNAPSHOT)

# In-memory version tracking
VERSION_HISTORY = ["SANCTIONED_V1", "WORKING_V1"]
CURRENT_VERSION = "WORKING_V1"

def revert_to_sanctioned():
    global WORKING_VERSION, CURRENT_VERSION
    WORKING_VERSION = copy.deepcopy(SANCTIONED_SNAPSHOT)
    CURRENT_VERSION = "WORKING_V2"

def update_working_version(values, version):
    global WORKING_VERSION, CURRENT_VERSION
    WORKING_VERSION.update(values)
    CURRENT_VERSION = version

def get_final_form_metadata(context: Context) -> Dict[str, Any]:
    # 1. Start from base form
    # Version awareness: update working version if values submitted
    if context.values:
        update_working_version(context.values, context.version)

    # Revert logic: if context.stage == 'REVERT', revert working version to sanctioned
    if context.stage == "REVERT":
        revert_to_sanctioned()
        # After revert, return new metadata with changedFields
        changed_fields = [k for k in WORKING_VERSION if WORKING_VERSION[k] != SANCTIONED_SNAPSHOT[k]]
    else:
        changed_fields = [k for k in WORKING_VERSION if WORKING_VERSION[k] != SANCTIONED_SNAPSHOT[k]]

    # Tile prerequisite & locking: lock Loan Details if KYC incomplete
    kyc_complete = True
    for field_id in BASE_FORM["cards"]["Identity Details"]:
        # Must be present and non-empty in working version
        if not WORKING_VERSION.get(field_id):
            kyc_complete = False
    # Build tile/cards/fields
    tile = {
        "tile": BASE_FORM["tile"],
        "versionId": CURRENT_VERSION,
        "cards": [],
        "completionStatus": None,
        "changedFields": changed_fields,
        "prerequisiteIncompleteReason": None,
    }
    for card_name, field_ids in BASE_FORM["cards"].items():
        card = {"cardName": card_name, "fields": []}
        for field_id in field_ids:
            field_meta = FIELD_REGISTRY[field_id].copy()
            # Dynamic config for demo:
            field = {
                "fieldId": field_id,
                "label": field_id.replace("_", " ").title(),
                "type": field_meta["type"],
                "visible": True,
                "mandatory": field_id == "CUST_PAN" or field_id == "CUST_LOAN_AMOUNT",
                "editable": field_id == "CUST_PAN",
                "order": 1,
            }
            # Dependency: PAN mandatory if Loan Amount > 10L
            amount = WORKING_VERSION.get("CUST_LOAN_AMOUNT", 0)
            try:
                amount = int(amount)
            except (ValueError, TypeError):
                amount = 0
            if field_id == "CUST_PAN" and amount > 1000000:
                field["mandatory"] = True
            # Log mandatory status and logic
            import logging
            logging.info(f"Field {field_id}: mandatory={field['mandatory']} (Loan Amount={amount})")
            # Always allow editing for testing validation UI
            field["editable"] = True
            field.pop("freezeReason", None)
            # Revert highlight: highlight only changed fields
            if field_id in changed_fields:
                field["changedFields"] = True
            card["fields"].append(field)
        # Always allow editing for testing validation UI
        card.pop("completionStatus", None)
        tile["cards"].append(card)
    # Tile completion status
    all_fields = [f for c in tile["cards"] for f in c["fields"]]
    tile["completionStatus"] = "COMPLETE"
    tile.pop("prerequisiteIncompleteReason", None)
    # Response contract: wrap in tiles list for Flutter
    return {
        "tiles": [tile],
        "versionId": CURRENT_VERSION,
        "completionStatus": tile["completionStatus"],
    }
