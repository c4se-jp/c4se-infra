# coding=UTF-8
"""API GET random."""
from common import (
    logger,
    RandomRepo
)
import re
import traceback


class EventValidationException(Exception):
    """Fail to validate event."""

    def __str__(self):
        """To string."""
        return "400: %s" % self.message


def validate_event(event):
    """Validate request params."""
    for key in ["id", "stage"]:
        if key not in event:
            raise EventValidationException("Event should have `%s`." % key)
    if not re.match(r"\A[0-9A-Za-z]+\Z", event["id"]):
            raise EventValidationException("`id` should match [0-9A-Za-z]+")
    if event["stage"] not in ["staging", "prod"]:
        raise EventValidationException("`stage` should be 'staging' or 'prod'.")


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
        m = re.match(r"\A\d{3}: ", e.__str__())
        if (not m) or (m and m.group(0)[0:3] not in ["400", "500"]):
            e = Exception("500: %s" % e)
        raise e
