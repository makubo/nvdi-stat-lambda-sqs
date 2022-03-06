#!/usr/bin/env python

import os
import dateutil.parser
from datetime import date, timedelta
from sentinelhub import SHConfig, SentinelHubStatistical, \
  DataCollection, CRS, BBox, bbox_to_dimensions

config = SHConfig()

config.instance_id = os.getenv('SH_INSTANCE_ID')
config.sh_client_id = os.getenv('SH_CLIENT_ID')
config.sh_client_secret = os.getenv('SH_CLIENT_SECRET')

config.aws_access_key_id = os.getenv('AWS_ACCESS_KEY_ID')
config.aws_secret_access_key = os.getenv('AWS_SECRET_ACCESS_KEY')

today = date.today()
two_week_before = today - timedelta(days=14)

# default region
#region_coords_wgs84 = [139.0, 35.5, 140.0, 34.5]

with open('ndvi_evalscript.js') as f:
  content = f.readlines()

ndvi_evalscript = "".join(content)

def collect_stats(region):

  if isinstance(region, list) and len(region) == 4:
    region_coords_wgs84 = region
  else:
    print(f"Region input error: {region}")
    return "Region input error"

  region_bbox = BBox(bbox=region_coords_wgs84, crs=CRS.WGS84)

  resolution = 60
  region_size = bbox_to_dimensions(region_bbox, resolution=resolution)

  stat_request = SentinelHubStatistical(
    aggregation=SentinelHubStatistical.aggregation(
      evalscript=ndvi_evalscript,
      time_interval=(two_week_before.strftime("%Y-%m-%d"), today.strftime("%Y-%m-%d")),
      aggregation_interval='P1D',
      size=region_size
    ),
    input_data=[
      SentinelHubStatistical.input_data(
        DataCollection.SENTINEL2_L1C
      )
    ],
    bbox=region_bbox,
    config=config
  )
  
  stat_data = stat_request.get_data()[0]["data"]
  
  latest_date = None
  latest_index = 0
  
  for i in range(len(stat_data)):
    temp_date = dateutil.parser.isoparse(stat_data[i]["interval"]["to"])
    if latest_date is None or temp_date > latest_date:
      latest_date = temp_date
      latest_index = i
  
  # Latest values object
  stat_values = stat_data[latest_index]["outputs"]["ndvi"]["bands"]["B0"]["stats"]
  
  max = stat_values["max"]
  min = stat_values["min"]
  mean = stat_values["mean"]
  stDev = stat_values["stDev"]
  
  result = {}
  
  result["date"] = latest_date.strftime('%Y-%m-%d')
  result["min"] = min
  result["max"] = max
  result["mean"] = mean
  result["variance"] = stDev ** 2
  result["standard_deviation"] = stDev
  result["region"] = region_coords_wgs84
  
  return result
