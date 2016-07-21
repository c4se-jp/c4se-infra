# coding=UTF-8
"""API GET random."""
from common import (
    logger,
    RandomRepo
)
import traceback


def validate_event(event):
    """Validate request params."""
    for key in ["id", "stage"]:
        if key not in event:
            raise Exception("Event must have `%s`." % key)


def main(event, context):
    """Lambda handler."""
    try:
        logger.info(event)
        validate_event(event)
        repo = RandomRepo(event["stage"])
        item = repo.find(event["id"])
        return {
            "id": item.id,
            "code": item.code
        }
    except Exception as e:
        logger.error("%s\n%s" % (e, traceback.format_exc()))
        raise
