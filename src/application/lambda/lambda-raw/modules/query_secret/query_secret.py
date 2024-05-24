import base64
import json

import boto3


def extract_api_token_from_secret(
    secret_name: str, api_token_key_name: str, region_name: str
) -> str:
    """
    Retrieves API token from AWS Secrets Manager.

    Args:
    secret_name (str): Name of the secret.
    api_token_key_name (str): Key of the API token within the secret.
    region_name (str): AWS region name.

    Returns:
    str: The API token.
    """
    session = boto3.session.Session()
    client = session.client(
        service_name="secretsmanager", region_name=region_name
    )

    get_secret_value_response = client.get_secret_value(SecretId=secret_name)

    if "SecretString" in get_secret_value_response:
        secret = get_secret_value_response["SecretString"]
    else:
        secret = base64.b64decode(get_secret_value_response["SecretBinary"])

    api_token = json.loads(secret)[api_token_key_name]
    return api_token
