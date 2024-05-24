import json
import logging
import os
from datetime import datetime, timezone

import boto3
from botocore.exceptions import BotoCoreError, ClientError
from modules.query_api.query_api import query_api
from modules.query_secret.query_secret import extract_api_token_from_secret

# Set up logging
logger = logging.getLogger()
logger.setLevel("INFO")

if __name__ != "__main__":
    LAMBDA_SECRET_NAME = os.environ["LAMBDA_SECRET_NAME"]
    API_TOKEN_API_KEY_NAME = os.environ["API_TOKEN_API_KEY_NAME"]
    REGION_NAME = os.environ["REGION_NAME"]
    OPENAQ_API_KEY = extract_api_token_from_secret(
        LAMBDA_SECRET_NAME, API_TOKEN_API_KEY_NAME, REGION_NAME
    )

    COUNTRY = os.environ["COUNTRY"]
    S3_BUCKET_NAME = os.environ["S3_BUCKET_NAME"]

OPENAQ_RESULTS_LIMIT = 20000
OPENAQ_URL = (
    f"https://api.openaq.org/v2/latest?limit={OPENAQ_RESULTS_LIMIT}&page=1"
    "&offset=0&sort=desc&radius=1000&order_by=lastUpdated&dump_raw=false"
)


def lambda_handler(event: dict, context: dict) -> dict:
    """
    AWS Lambda function handler.
    Queries the OpenAQ API for the latest measurements,
    filters them by country, splits the measurements by
    individual measurements of today, and uploads the results to S3.

    Parameters:
    event (dict): Incoming event data
    context (dict): AWS Lambda context

    Returns:
    dict: Response with status code and body message
    """
    try:
        # Query the OpenAQ API
        json_raw_response = query_api(
            OPENAQ_URL, OPENAQ_API_KEY, OPENAQ_RESULTS_LIMIT
        )

        # Filter the results by country
        json_raw_response_BE = [
            result
            for result in json_raw_response["results"]
            if result["country"] == COUNTRY
        ]
        logging.info(
            (
                f"Number of items API of country {COUNTRY}: "
                f"{len(json_raw_response_BE)}"
            )
        )

        json_raw_response_BE_splitted = []
        last_updated_times = []
        today = datetime.now().date()

        for item in json_raw_response_BE:
            for measurement in item["measurements"]:
                # Copy the item to preserve the metadata
                new_item = item.copy()
                # Replace the 'measurements' field with the single measurement
                new_item.update(measurement)
                del new_item["measurements"]

                # Convert 'lastUpdated' to a date and check if it's today
                last_updated_time = datetime.fromisoformat(
                    new_item["lastUpdated"].replace("Z", "+00:00")
                )
                if last_updated_time.date() == today:
                    json_raw_response_BE_splitted.append(new_item)
                    last_updated_times.append(last_updated_time)

        logging.info(
            (
                f"Number of items API of country {COUNTRY} "
                f"of today and splitted: {len(json_raw_response_BE_splitted)}"
            )
        )

        time_earliest = min(last_updated_times).strftime("%Y-%m-%d-%H-%M-%S")
        time_latest = max(last_updated_times).strftime("%Y-%m-%d-%H-%M-%S")
        logging.info(f"Earliest time of items: {time_earliest}")
        logging.info(f"Latest time of items: {time_latest}")

        # Upload the final JSON to S3
        s3 = boto3.client("s3")
        now = datetime.now(timezone.utc).strftime("%Y-%m-%d-%H-%M-%S")
        s3_key = f"{now}.json"
        s3.put_object(
            Bucket=S3_BUCKET_NAME,
            Key=s3_key,
            Body=json.dumps(json_raw_response_BE_splitted),
            Metadata={
                "time_earliest_data": time_earliest,
                "time_latest_data": time_latest,
            },
        )
        logging.info(
            f"S3 object {s3_key} ingested in bucket: {S3_BUCKET_NAME}"
        )

        return {
            "statusCode": 200,
            "body": json.dumps(
                (
                    "Successfully processed latest OPENAQ measurements "
                    "and ingested into S3!"
                )
            ),
        }
    except (BotoCoreError, ClientError) as e:
        logging.error(f"Error interacting with S3: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps(
                "Error processing messages: could not interact with S3"
            ),
        }
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps("Error processing messages: unexpected error"),
        }


if __name__ == "__main__":
    # Define event, context, and environment variables as needed
    event = {}
    context = {}

    # Reading the OpenAQ API key from a local file
    # local_open_api_key_path = "data/01_raw/openaq-api-key.txt"
    # with open(local_open_api_key_path, "r") as file:
    #     OPENAQ_API_KEY = file.read().strip()

    # Reading the OpenAQ API key from AWS Secrets Manager
    LAMBDA_SECRET_NAME = "lambda-raw-lambda-secret-Wy76f"
    API_TOKEN_API_KEY_NAME = "OPENAQ_API_KEY"
    REGION_NAME = "us-east-1"
    OPENAQ_API_KEY = extract_api_token_from_secret(
        LAMBDA_SECRET_NAME, API_TOKEN_API_KEY_NAME, REGION_NAME
    )

    COUNTRY = "BE"
    S3_BUCKET_NAME = "bucket-raw-4i4y"

    # Call the lambda_handler function
    lambda_handler(event, context)
