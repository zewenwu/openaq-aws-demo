import os
import uuid

import pandas as pd
from modules.dynamodb_query.dynamodb_query import query_dynamodb_last_hours
from modules.plots.make_save_plots import (
    make_save_bar_plot,
    make_save_dist_plot,
    make_save_folium_map_html,
)
from modules.s3_upload.s3_upload import upload_files_to_s3

if __name__ != "__main__":
    S3_BUCKET_NAME = os.environ["S3_BUCKET_NAME"]
    DYNAMODB_TABLE_NAME = os.environ["DYNAMODB_TABLE_NAME"]
    REGION_NAME = os.environ["REGION_NAME"]
    QUERY_HOURS = int(os.environ["QUERY_HOURS"])

    LAMBDA_TMP_PREFIX = "/tmp/{}".format(uuid.uuid4())
    LOCAL_MAP_HTML_FILE = "{}_map_latest.html".format(LAMBDA_TMP_PREFIX)
    LOCAL_DATA_HTML_FILE = "{}_data_latest.html".format(LAMBDA_TMP_PREFIX)
    LOCAL_DATA_HTML_FILE_TEMPLATE = "modules/s3_upload/index_template.html"
    LOCAL_BAR_PNG_FILE = "{}_bar_latest.png".format(LAMBDA_TMP_PREFIX)
    LOCAL_DIST_PNG_FILE = "{}_dist_latest.png".format(LAMBDA_TMP_PREFIX)

# Define the file paths for the plots

S3_BAR_PNG_FILE = "img/bar_latest.png"
TOP_BAR = 20

S3_DIST_PNG_FILE = "img/dist_latest.png"
TOP_DIST = 10

# Define the file paths for the HTML files to save to S3
ADD_LOCATIONS_ON_MAP = True
S3_DATA_HTML_FILE = "data_index.html"
S3_MAP_HTML_FILE = "index.html"

# Define the date formats
DATE_FORMAT_QUERY = "%Y-%m-%dT%H:%M:%S%z"
DATE_FORMAT_PLOTS = "%Y-%m-%d %H:%M"


def lambda_handler(event: dict, context: dict) -> dict:
    """
    AWS Lambda function handler.

    Parameters:
    event (dict): Data from the lambda trigger.
    context (LambdaContext): Information about the runtime.

    Returns:
    dict: Response with status code and body.
    """

    # Query DynamoDB for items from the last specified hours
    from_time, to_time, items = query_dynamodb_last_hours(
        DYNAMODB_TABLE_NAME,
        QUERY_HOURS,
        REGION_NAME,
        DATE_FORMAT_QUERY,
        DATE_FORMAT_PLOTS,
    )
    num_measurements = len(items)
    if num_measurements == 0:
        return {
            "statusCode": 200,
            "body": f"No items found in the last {QUERY_HOURS} hours.",
        }

    # Convert the items to a DataFrame
    df = pd.DataFrame(items)

    # Calculate the average pollutants for each location and parameter
    # Assumes all location have same longitude and latitude
    df_avg_value_parameters = (
        df.groupby(["location", "parameter"])
        .agg(
            {
                "value": ["mean", "count"],
                "longitude": "first",
                "latitude": "first",
            }
        )
        .reset_index()
    )

    # Flatten the MultiIndex columns
    df_avg_value_parameters.columns = [
        "_".join(col).strip() for col in df_avg_value_parameters.columns.values
    ]

    # Rename the columns
    df_avg_value_parameters.rename(
        columns={
            "location_": "location",
            "parameter_": "parameter",
            "value_mean": "avg_pollutants",
            "value_count": "num_measurements",
            "longitude_first": "longitude",
            "latitude_first": "latitude",
        },
        inplace=True,
    )

    # Calculate the sum of average pollutants for each location
    df_sum_parameters = (
        df_avg_value_parameters.groupby("location")
        .agg(
            {
                "avg_pollutants": "sum",
                "num_measurements": "sum",
                "longitude": "first",
                "latitude": "first",
            }
        )
        .reset_index()
    )

    df_sum_parameters.rename(
        columns={"avg_pollutants": "sum_avg_pollutants"}, inplace=True
    )

    # Plot the results
    make_save_folium_map_html(
        df_sum_parameters,
        ADD_LOCATIONS_ON_MAP,
        LOCAL_MAP_HTML_FILE,
    )
    make_save_bar_plot(
        from_time,
        to_time,
        num_measurements,
        df_sum_parameters,
        df_avg_value_parameters,
        TOP_BAR,
        LOCAL_BAR_PNG_FILE,
    )
    make_save_dist_plot(
        from_time,
        to_time,
        num_measurements,
        df_sum_parameters,
        TOP_DIST,
        LOCAL_DIST_PNG_FILE,
    )

    # Save the DataFrame to S3
    png_files = [
        # (LOCAL_MAP_HTML_FILE, S3_MAP_HTML_FILE),
        (LOCAL_BAR_PNG_FILE, S3_BAR_PNG_FILE),
        (LOCAL_DIST_PNG_FILE, S3_DIST_PNG_FILE),
    ]
    upload_files_to_s3(
        from_time,
        to_time,
        S3_BUCKET_NAME,
        REGION_NAME,
        df_sum_parameters,
        df_avg_value_parameters,
        LOCAL_DATA_HTML_FILE,
        S3_DATA_HTML_FILE,
        LOCAL_DATA_HTML_FILE_TEMPLATE,
        LOCAL_MAP_HTML_FILE,
        S3_MAP_HTML_FILE,
        png_files,
    )

    return {"statusCode": 200, "body": "Results saved to S3."}


if __name__ == "__main__":
    # Define event, context, and environment variables as needed
    event = {}
    context = {}
    S3_BUCKET_NAME = "bucket-refined-ad29"
    DYNAMODB_TABLE_NAME = "table-clean"
    REGION_NAME = "us-east-1"
    QUERY_HOURS = 12

    LOCAL_TMP_PREFIX = "data/00_test"
    LOCAL_MAP_HTML_FILE = "{}/map_latest.html".format(LOCAL_TMP_PREFIX)
    LOCAL_DATA_HTML_FILE = "{}/data_latest.html".format(LOCAL_TMP_PREFIX)
    LOCAL_DATA_HTML_FILE_TEMPLATE = (
        "src/application/lambda/lambda-refined/"
        "modules/s3_upload/index_template.html"
    )
    LOCAL_BAR_PNG_FILE = "{}/bar_latest.png".format(LOCAL_TMP_PREFIX)
    LOCAL_DIST_PNG_FILE = "{}/dist_latest.png".format(LOCAL_TMP_PREFIX)

    # Call the lambda_handler
    lambda_handler(event, context)
