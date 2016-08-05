"""CRUD random."""
from common import logger
import get_random
import put_random
import re
import traceback


def handler(event, context):
    """Lambda handler."""
    logger.info(event)
    try:
        if event.get("httpMethod") == "GET":
            return get_random.handler(event, context)
        elif event.get("httpMethod") == "PUT":
            return put_random.handler(event, context)
        else:
            raise NotImplementedError("400: Method Not Allowed: %s" % context.httpMethod)
    except Exception as e:
        logger.error("%s\n%s" % (e, traceback.format_exc()))
        m = re.match(r"\A\d{3}: ", e.__str__())
        if (not m) or (m and m.group(0)[0:3] not in ["400", "500"]):
            e = Exception("500: %s" % e)
        raise e
