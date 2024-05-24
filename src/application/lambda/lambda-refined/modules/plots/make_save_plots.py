import logging

import cartopy.crs as ccrs
import cartopy.feature as cfeature
import folium
import geopandas as gpd
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from scipy import stats

# Set up logging
logger = logging.getLogger()
logger.setLevel("INFO")

MEASUREMENT_UNIT = "µg/m³"


def make_save_folium_map_html(
    df_sum_parameters: pd.DataFrame,
    add_locations: bool = False,
    file_name: str = "follium_map.html",
) -> None:
    """
    Create a Folium map plot and save it.

    Parameters:
    df_sum_parameters (pd.DataFrame): The data to plot.
    add_locations (bool, optional): Whether to add the locations to the plot.
    file_name (str, optional): The name of the file to save the plot to.

    Returns:
    None
    """
    m = folium.Map(location=[50.5, 4.5], zoom_start=8)
    cmap = sns.cubehelix_palette(
        start=2, rot=0, dark=0, light=0.95, reverse=False, as_cmap=True
    )
    norm = plt.Normalize(
        df_sum_parameters["sum_avg_pollutants"].min(),
        df_sum_parameters["sum_avg_pollutants"].max(),
    )

    # Add points to the map instance
    for i in range(len(df_sum_parameters)):
        color = plt.cm.colors.to_hex(
            cmap(norm(df_sum_parameters["sum_avg_pollutants"].iloc[i]))
        )
        radius = (
            df_sum_parameters["sum_avg_pollutants"].iloc[i] / 10
        )  # Adjust this value to get the desired effect
        folium.CircleMarker(
            location=[
                df_sum_parameters.latitude.iloc[i],
                df_sum_parameters.longitude.iloc[i],
            ],
            radius=radius,
            color=color,
            fill=True,
            fill_color=color,
        ).add_to(m)

        # Add number of measurements and location name to each marker
        if add_locations:
            folium.Marker(
                [
                    df_sum_parameters.latitude.iloc[i],
                    df_sum_parameters.longitude.iloc[i],
                ],
                popup=(
                    f"Location: {df_sum_parameters.location.iloc[i]}\n"
                    "SumAveragePollutants: "
                    f"{df_sum_parameters.sum_avg_pollutants.iloc[i]}\n"
                    "MeasurementsUsed: "
                    f"{df_sum_parameters.num_measurements.iloc[i]}"
                ),
            ).add_to(m)

    # Save it as html file
    m.save(file_name)
    logging.info("Folium Map plot created and saved to %s.", file_name)


# Not used in the latest version of the application
def make_save_cartopy_map_plot(
    from_time: str,
    to_time: str,
    num_measurements: int,
    df_sum_parameters: pd.DataFrame,
    add_locations: bool = False,
    file_name: str = "cartopy_map.png",
) -> None:
    """
    Create a Cartopy map plot and save it.

    Parameters:
    from_time (str): The start time for the data.
    to_time (str): The end time for the data.
    num_measurements (int): The number of measurements.
    df_sum_parameters (pd.DataFrame): The data to plot.
    add_locations (bool, optional): Whether to add the locations to the plot.
    file_name (str, optional): The name of the file to save the plot to.

    Returns:
    None
    """

    # Define the Cartopy CRS for the plot
    crs = ccrs.PlateCarree()

    # Create a GeoDataFrame
    gdf = gpd.GeoDataFrame(
        df_sum_parameters,
        geometry=gpd.points_from_xy(
            df_sum_parameters.longitude, df_sum_parameters.latitude
        ),
    )

    # Create a figure and axes with the specified CRS
    fig, ax = plt.subplots(figsize=(10, 10), subplot_kw={"projection": crs})

    # Set the extent of the map to Belgium's coordinates
    ax.set_extent([2.5, 6.5, 49.5, 51.5], crs=crs)

    # Add country borders
    countries = cfeature.NaturalEarthFeature(
        category="cultural",
        name="admin_0_boundary_lines_land",
        scale="10m",
        facecolor="none",
    )

    ax.add_feature(countries, edgecolor="black")

    # Plot the data points
    scatter = ax.scatter(
        gdf["longitude"],
        gdf["latitude"],
        c=gdf["sum_avg_pollutants"],
        cmap="viridis",
        alpha=0.5,
        s=20,
        transform=crs,
    )

    # Add number of measurements and location name to each marker
    if add_locations:
        for i in range(len(gdf)):
            ax.text(
                gdf.longitude.iloc[i],
                gdf.latitude.iloc[i],
                f"{gdf.location.iloc[i]}:{gdf.num_measurements.iloc[i]}",
                transform=crs,
                fontsize=6,
            )

    if add_locations:
        plt.title(
            (
                f"Polluted locations in Belgium, "
                f"{num_measurements} ticks measured\n"
                f"between {from_time} and {to_time} UTC\n"
                f"Format of datapoints <LOCATION>:<NUM_MEASUREMENTS>"
            )
        )
    else:
        plt.title(
            (
                f"Polluted locations in Belgium, "
                f"{num_measurements} ticks measured\n"
                f"between {from_time} and {to_time} UTC"
            )
        )

    # Add a colorbar
    cbar = plt.colorbar(scatter, shrink=0.4)
    cbar.set_label(f"Sum Average Pollutants [{MEASUREMENT_UNIT}]")

    # Save the plot
    plt.subplots_adjust(top=0.95, bottom=0.05)
    plt.tight_layout()
    plt.savefig(file_name)
    logging.info("Cartopy Map plot created and saved to %s.", file_name)


def make_save_bar_plot(
    from_time: str,
    to_time: str,
    num_measurements: int,
    df_sum_parameters: pd.DataFrame,
    df_avg_value_parameters: pd.DataFrame,
    top_bar: int = 20,
    file_name: str = "bar.png",
) -> None:
    """
    Generates and saves a bar plot of top pollutant locations
    in a given time range.

    Parameters:
    from_time (str): Start of the time range in 'YYYY-MM-DD HH:MM:SS' format.
    to_time (str): End of the time range in 'YYYY-MM-DD HH:MM:SS' format.
    num_measurements (int): Number of measurements.
    df_sum_parameters (pd.DataFrame): DataFrame with sum of average pollutants
    per location and parameter.
    df_avg_value_parameters (pd.DataFrame): DataFrame with
    average parameter values per location.
    top_bar (int, optional): Number of top locations to plot.
    file_name (str, optional): Name of the file to save the plot to.

    Returns:
    None
    """
    # Sort by total avg_pollutants and select top 10
    top_locations = (
        df_sum_parameters.sort_values("sum_avg_pollutants", ascending=False)
        .head(top_bar)["location"]
        .values
    )

    # Filter original DataFrame to only include top 10 locations
    df_top_locations = df_avg_value_parameters[
        df_avg_value_parameters["location"].isin(top_locations)
    ]

    # Pivot the data for the bar chart
    df_pivot = df_top_locations.pivot(
        index="location", columns="parameter", values="avg_pollutants"
    ).infer_objects(copy=False)

    # Sort the DataFrame by the sum of each row
    df_pivot = df_pivot.loc[
        df_pivot.sum(axis=1).sort_values(ascending=False).index
    ]

    # Plot a stacked bar chart
    df_pivot.plot(kind="bar", stacked=True)
    plt.title(
        (
            f"Top {top_bar} most polluted location in Belgium, "
            f"{num_measurements} ticks measured \n"
            f"between {from_time} and {to_time} UTC"
        )
    )
    plt.xlabel("Location")
    plt.xticks(rotation=80)
    plt.ylabel(f"Sum of Average Pollutants [{MEASUREMENT_UNIT}]")
    # plt.ylim([6, plt.ylim()[1]])
    plt.legend(title="Pollutant", bbox_to_anchor=(1.05, 1), loc="upper left")
    plt.tight_layout()
    plt.grid(alpha=0.2)
    plt.savefig(file_name, dpi=600)
    logging.info("Bar plot created and saved to %s.", file_name)


def make_save_dist_plot(
    from_time: str,
    to_time: str,
    num_measurements: int,
    df_sum_parameters: pd.DataFrame,
    top_dist: int = 10,
    file_name: str = "dist.png",
) -> None:
    """
    Creates and saves a distribution plot of top pollutant locations.

    Parameters:
    - from_time (str): Start time for data range.
    - to_time (str): End time for data range.
    - num_measurements (int): Number of measurements.
    - df_sum_parameters (pd.DataFrame): DataFrame with
      sum of average pollutants.
    - top_dist (int, optional): Number of top locations to plot.
      Defaults to 10.
    - file_name (str, optional): File name to save the plot.
      Defaults to "dist.png".

    Returns:
    - None: The function saves the plot to a file.
    """

    # Sort by total avg_pollutants and select top polluting cities
    df_sum_parameters_sorted = df_sum_parameters.sort_values(
        "sum_avg_pollutants", ascending=False
    )
    top_cities = df_sum_parameters_sorted.head(top_dist)

    # Calculate histogram
    counts, bins = np.histogram(df_sum_parameters["sum_avg_pollutants"])

    # Plotting
    plt.figure(figsize=(10, 6))
    sns.histplot(
        df_sum_parameters["sum_avg_pollutants"],
        kde=True,
        color="gray",
        bins=bins,
    )
    sns.rugplot(
        top_cities["sum_avg_pollutants"], height=1, color="blue", alpha=0.5
    )

    # Annotate top 10 cities with shifted text and percentile
    start_offset = 0.5
    max_offset = max(counts)
    for i in range(top_cities.shape[0]):
        offset = (i / (top_dist - 1)) * max_offset if top_dist > 1 else 0
        percentile = stats.percentileofscore(
            df_sum_parameters["sum_avg_pollutants"],
            top_cities["sum_avg_pollutants"].iloc[i],
        )
        plt.text(
            top_cities["sum_avg_pollutants"].iloc[i],
            start_offset + offset,
            f"{top_cities['location'].iloc[i]} ({percentile:.1f}%)",
            color="black",
            rotation=-10,
            fontsize=10,
        )

    plt.title(
        (
            f"Distribution of Sum of Average Pollutants in Belgium, "
            f"{num_measurements} ticks measured\n"
            f"between {from_time} and {to_time} UTC"
        )
    )
    plt.xlabel(f"Sum of Average Pollutants [{MEASUREMENT_UNIT}]")
    plt.ylabel("Density")

    # Set y limit to max count
    plt.ylim(0, max(counts) + 10)
    plt.tight_layout()
    plt.grid(alpha=0.2)
    plt.savefig(file_name, dpi=600)
    logging.info("Distribution plot created and saved to %s.", file_name)
