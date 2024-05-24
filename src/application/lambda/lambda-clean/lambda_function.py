import decimal
import json
import logging
import os
import time
import uuid
from datetime import datetime, timezone
from urllib.parse import unquote_plus

import boto3
from botocore.exceptions import BotoCoreError, ClientError

# Set up logging
logger = logging.getLogger()
logger.setLevel("INFO")

if __name__ != "__main__":
    DYNAMODB_TABLE_NAME = os.environ["DYNAMODB_TABLE_NAME"]
    REGION_NAME = os.environ["REGION_NAME"]

TTL_DURATION = 86400 * 2  # 48 hours
DATE_FORMAT = "%Y-%m-%dT%H:%M:%S%z"
ACCEPTED_PARAMS = ["no", "no2", "so2", "pm1", "pm10", "pm25", "o3", "co"]
ACCEPTED_UNITS = ["µg/m³", "mg/m³"]


def lambda_handler(event: dict, context: dict) -> dict:
    """
    AWS Lambda function handler.
    Processes incoming events, extracts records, and stores them in DynamoDB.

    Parameters:
    event (dict): Incoming event data
    context (dict): AWS Lambda context

    Returns:
    dict: Response with status code and body message
    """
    try:
        # Initialize S3 client
        s3_client = boto3.client("s3")

        # Initialize DynamoDB client
        dynamodb = boto3.resource("dynamodb", region_name=REGION_NAME)
        table = dynamodb.Table(
            DYNAMODB_TABLE_NAME
        )  # get table name from environment variable

        # Process each record
        for record in event["Records"]:
            process_record(record, s3_client, table)

        return {
            "statusCode": 200,
            "body": json.dumps(
                "Successfully processed items: ingested into DynamoDB!"
            ),
        }
    except (BotoCoreError, ClientError) as e:
        logging.error(f"Error interacting with Boto3 Client: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps(
                (
                    "Error processing items: ",
                    "could not interact with Boto3 client",
                )
            ),
        }
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps("Error processing items: unexpected error"),
        }


def process_record(record: dict, s3_client, table) -> None:
    """
    Process a single record, download the json from S3,
    process each item, and store it in DynamoDB.

    Parameters:
    record (dict): The record to process
    table: The DynamoDB table to store the item in
    """
    # Download and open the file from S3 that has triggered the Lambda function
    bucket = record["s3"]["bucket"]["name"]
    key = unquote_plus(record["s3"]["object"]["key"])
    tmpkey = key.replace("/", "")
    download_path = "/tmp/{}_{}".format(uuid.uuid4(), tmpkey)
    s3_client.download_file(bucket, key, download_path)
    log = f"JSON DOWNLOADED FROM S3 TO: {download_path}"
    logging.info(log)

    with open(download_path, "r") as file:
        s3_json = json.load(file, parse_float=decimal.Decimal)

    # Process each item in the S3 JSON
    skipped_items = 0
    ingested_items = 0
    for item in s3_json:
        # Process the JSON item
        processed_item = process_json_item(item)
        if processed_item is None:
            log = f"ITEM SKIPPED: {item}"
            logging.info(log)
            skipped_items += 1
            continue

        # Ingest the processed item into DynamoDB
        table.put_item(Item=processed_item)
        ingested_items += 1

    log = (
        f"INGESTED ITEMS INTO DYNAMODB: {ingested_items}, "
        f"SKIPPED ITEMS: {skipped_items}"
    )
    logging.info(log)


def process_json_item(item: json) -> json:
    """
    Process a single json item.
    Check for validity and clean the item.

    Parameters:
    item (json): The item to process
    """
    # Check validity: check if the item has right units,
    # strict positive values or is a an accepted parameter
    if (
        (item["value"] <= 0)
        or (item["parameter"] not in ACCEPTED_PARAMS)
        or (item["unit"] not in ACCEPTED_UNITS)
    ):
        # Skip the item if it's not valid
        return None

    # Check if the item has a valid location string,
    # otherwise set it to "Unknown"
    if item["location"] is None:
        item["location"] = "Unknown"
    else:
        # Trim white spaces for location attribute
        item["location"] = item["location"].strip()

    # Trim white spaces for city attribute
    if item["city"] is not None:
        item["city"] = item["city"].strip()

    # Convert the units to micrograms per cubic meter
    if item["unit"] == "mg/m³":
        item["value"] *= 1000
        item["unit"] = "µg/m³"
    elif item["unit"] != "µg/m³":
        raise ValueError(f"Unknown unit detected: {item['unit']}")

    # Convert the coordinates to latitude and longitude attributes
    item["latitude"] = item["coordinates"]["latitude"]
    item["longitude"] = item["coordinates"]["longitude"]
    del item["coordinates"]

    # Define a Time to Live (TTL) epoch time attribute
    date_object = datetime.strptime(item["lastUpdated"], DATE_FORMAT)
    item["expireAt"] = int(time.mktime(date_object.timetuple())) + TTL_DURATION

    # Define a ingestedAt time attribute using the current UTC time
    item["ingestedAt"] = datetime.now(timezone.utc).strftime(DATE_FORMAT)

    return item


if __name__ == "__main__":
    DYNAMODB_TABLE_NAME = "table-clean"
    REGION_NAME = "us-east-1"

    event = {
        "Records": [
            {
                "s3": {
                    "bucket": {"name": "bucket-raw-zfiy"},
                    "object": {"key": "example-s3-json.json"},
                }
            }
        ]
    }
    context = {}
    lambda_handler(event, context)
