"""Dummy heartbeat endpoint."""
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):
    """Lambda handler."""
    logger.info(event)
    if "stage" not in event:
        raise Exception("Event must have `stage`.")
    return "ok"
