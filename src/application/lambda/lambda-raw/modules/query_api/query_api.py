import json
import logging

import requests

# Set up logging
logging.basicConfig(level=logging.INFO)


def query_api(url: str, api_key: str, max_items: int) -> dict:
    """
    Fetches tje latest air quality data from OpenAQ API.

    Args:
    url (str): API URL.
    api_key (str): API key.
    max_items (int): Max items to fetch.

    Returns:
    dict: API response content as JSON.
    """

    headers = {
        "accept": "application/json",
        "X-API-Key": api_key,
    }

    raw_response = requests.get(url, headers=headers)
    json_raw_response = json.loads(raw_response.text)
    logging.info(
        f"Number of items from API: {len(json_raw_response['results'])}, "
        f"Max items: {max_items}"
    )
    return json_raw_response
