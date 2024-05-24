import logging
from typing import List, Tuple

import boto3
import pandas as pd

# Set up logging
logger = logging.getLogger()
logger.setLevel("INFO")


def upload_files_to_s3(
    from_time: str,
    to_time: str,
    s3_bucket_name: str,
    region_name: str,
    df_sum_parameters: pd.DataFrame,
    df_avg_value_parameters: pd.DataFrame,
    local_data_html_file: str,
    s3_data_html_file: str,
    local_data_html_file_template: str,
    local_map_html_file: str,
    s3_map_html_file: str,
    png_files: List[Tuple[str, str]],
) -> None:
    """
    Uploads dataframes and images to an S3 bucket.

    Parameters:
    - from_time (str): Start of the time range in 'YYYY-MM-DD HH:MM:SS' format.
    - to_time (str): End of the time range in 'YYYY-MM-DD HH:MM:SS' format.
    - s3_bucket_name (str): Name of the S3 bucket.
    - region_name (str): Name of the AWS region.
    - df_sum_parameters (pd.DataFrame): Dataframe containing
      the sum of average pollutants.
    - df_avg_value_parameters (pd.DataFrame): Dataframe containing
      the average of pollutant molecules measured.
    - local_data_html_file (str): Name of the local data HTML file.
    - s3_data_html_file (str): Name of the data HTML file to save to S3.
    - local_data_html_file_template (str):
      Name of the local data HTML template file.
    - local_map_html_file (str): Name of the local map HTML file.
    - s3_map_html_file (str): Name of the map HTML file to save to S3.
    - png_files (List[Tuple[str, str]]): List of tuples
      where each tuple contains the local and s3 file names for each PNG file.

    Returns:
    - None
    """
    # Convert the DataFrames to HTML
    df_sum_parameters_html = df_sum_parameters.to_html(index=False)
    df_avg_value_parameters_html = df_avg_value_parameters.to_html(index=False)

    # Create the data HTML string
    with open(local_data_html_file_template, "r") as f:
        html_template = f.read()

    images_html = "".join(
        [
            f'<div class="image-container">'
            f'<img src="http://{s3_bucket_name}.s3-website-{region_name}.'
            f'amazonaws.com/{s3_file}" '
            f'alt="{s3_file}" class="img-fluid"></div>\n'
            for local_file, s3_file in png_files
        ]
    )

    html_string = html_template.format(
        images=images_html,
        from_time=from_time,
        to_time=to_time,
        df_sum_parameters_html=df_sum_parameters_html.replace(
            "table ", "table table-striped"
        ),
        df_avg_value_parameters_html=df_avg_value_parameters_html.replace(
            "table ", "table table-striped"
        ),
    )

    # Write the HTML string to a file
    with open(local_data_html_file, "w") as f:
        f.write(html_string)

    # Upload the plots and HTML file to S3
    s3_client = boto3.client("s3")
    for local_file, s3_file in png_files:
        s3_client.upload_file(
            local_file,
            s3_bucket_name,
            s3_file,
            ExtraArgs={
                "ContentType": "image/png",
                "CacheControl": "max-age=60",
            },
        )
        logging.info(f"local file {local_file} uploaded to S3: {s3_file}")
    s3_client.upload_file(
        local_data_html_file,
        s3_bucket_name,
        s3_data_html_file,
        ExtraArgs={"ContentType": "text/html"},
    )
    logging.info(
        (
            f"local file {local_data_html_file} "
            f"uploaded to S3: {s3_data_html_file}"
        )
    )
    s3_client.upload_file(
        local_map_html_file,
        s3_bucket_name,
        s3_map_html_file,
        ExtraArgs={"ContentType": "text/html"},
    )
    logging.info(
        f"local file {local_map_html_file} uploaded to S3: {s3_map_html_file}"
    )
    logging.info("All files uploaded to S3.")
