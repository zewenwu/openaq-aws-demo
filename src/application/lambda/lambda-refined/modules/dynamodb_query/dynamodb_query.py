import logging
from datetime import datetime, timedelta, timezone

import boto3
from boto3.dynamodb.conditions import Attr

# Set up logging
logger = logging.getLogger()
logger.setLevel("INFO")

DATE_ATTRIBUTE = "lastUpdated"
DATE_FORMAT_QUERY = "%Y-%m-%dT%H:%M:%S%z"
DATE_FORMAT_PLOTS = "%Y-%m-%d %H:%M"


def query_dynamodb_last_hours(
    dynamodb_table_name: str,
    hours: int = 3,
    region_name: str = "us-east-1",
    date_format_query: str = DATE_FORMAT_QUERY,
    date_format_plots: str = DATE_FORMAT_PLOTS,
) -> tuple:
    """
    Query DynamoDB for items from the last specified hours.

    Parameters:
    dynamodb_table_name (str): The name of the DynamoDB table.
    hours (int): The number of hours to look back. Default is 3.
    region_name (str): The AWS region name. Default is 'us-east-1'.
    date_format_query (str): The date format for the query.
    date_format_plots (str): The date format for the plots.

    Returns:
    tuple: A tuple containing the from_time, to_time, and the items found.
    """
    # Initialize DynamoDB client
    dynamodb = boto3.resource("dynamodb", region_name)
    table = dynamodb.Table(dynamodb_table_name)

    # Get the time of specified hours ago in the required format
    now = datetime.now(timezone.utc)
    hours_ago = now - timedelta(hours=hours)
    hours_ago_str = hours_ago.strftime(date_format_query)

    # Scan the table for items from the last specified hours
    logging.info(f"Scanning items of {hours} hours ago...")
    logging.info(
        f"Scanning items ingested after this UTC time: {hours_ago_str}..."
    )
    response = table.scan(
        FilterExpression=Attr(DATE_ATTRIBUTE).gt(hours_ago_str)
    )
    items = response["Items"]
    logging.info(f"Found {len(items)} items in the last {hours} hours.")

    from_time = hours_ago.strftime(date_format_plots)
    to_time = now.strftime(date_format_plots)
    return from_time, to_time, items
