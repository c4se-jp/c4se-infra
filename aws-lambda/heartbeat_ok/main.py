"""Dummy heartbeat endpoint."""


def main(event, context):
    """Lambda handler."""
    if "stage" not in event:
        raise Exception("Error: Event must have `stage`.")
    return "ok %s v1.0.1" % event["stage"]
