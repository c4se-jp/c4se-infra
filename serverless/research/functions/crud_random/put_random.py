# coding=UTF-8
"""API PUT random."""
from common import (
    EventValidationException,
    RandomRepo
)
import re


def validate_event(event):
    """Validate request params."""
    for key in ["id", "stage"]:
        if key not in event:
            raise EventValidationException("Event should have `%s`." % key)
    if re.match(r"\A[0-9A-Za-z]+\Z", event["id"]) is None:
            raise EventValidationException("`id` should match [0-9A-Za-z]+")
    if event["stage"] not in ["staging", "prod"]:
        raise EventValidationException("`stage` should be 'staging' or 'prod'.")


def handler(event, context):
    """Lambda handler."""
    repo = RandomRepo(event["stage"])
    item = repo.find(event["id"])
    repo.gen_code(item)
    return {
        "id": item.id,
        "code": item.code
    }
