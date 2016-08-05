# coding=UTF-8
"""Common codes for CRUD random."""
import boto3
import logging
import uuid

logger = logging.getLogger()
logger.setLevel(logging.INFO)


class EventValidationException(Exception):
    """Fail to validate event."""

    def __str__(self):
        """To string."""
        return "400: %s" % self.message


class Random(object):
    """Item of random table."""

    def __init__(self):
        """Initialize."""
        self.id = None
        self.code = None


class RandomRepo(object):
    """Random table."""

    def __init__(self, stage):
        """Initialize."""
        self.table = self.__get_table(stage)

    def find(self, id):
        """Find or initialize an item."""
        item = Random()
        item.id = id
        resp = self.table.get_item(
            Key={"id": id}
        )
        if "Item" in resp:
            item.code = resp["Item"]["code"]
        return item

    def gen_code(self, item):
        """Generate new code & update the item."""
        code = uuid.uuid4().hex
        self.table.put_item(
            Item={
                "id": item.id,
                "code": code
            }
        )
        item.code = code

    def __get_table(self, stage):
        if stage == "prod":
            table_name = "random"
        else:
            table_name = "s-random"
        return boto3.resource("dynamodb").Table(table_name)
