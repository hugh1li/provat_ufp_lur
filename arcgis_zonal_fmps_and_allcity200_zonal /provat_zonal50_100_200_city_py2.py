# extract values for all 200 grid cells and polygons. And then just select
# for 200m cell, qing_200m_cells_proj_id.shp, the grouping name is the 'PageNumber'


# python snippet
# Replace a layer/table view name with a path to a dataset (which can be a layer file) or create the layer/table view within the script
# The following inputs are layers or table views: "ACE_Polygons_project"
# arcpy.gp.ZonalStatisticsAsTable_sa("ACE_Polygons_project", "Name", "E:/GIS 12_06_15 backup/Raster GIS/Uptown_consulting.gdb/zonal_uptown_pm", "C:/Users/hugh/Desktop/ACE_zonal_table/testing", "DATA", "MEAN")


import arcpy, os, arcinfo
from arcpy import env
from arcpy.sa import *
arcpy.env.overwriteOutput = True
arcpy.CheckOutExtension("Spatial")

# Select the folder containing raster files.  This script will use ALL of
# the raster files in the selected folder. 
# env.workspace = "E:\GIS 12_06_15 backup\Raster GIS\qing_zonal\qing_zonal.gdb"
# traffic and landuse
# env.workspace = r"E:\GIS 12_06_15 backup\CAPS_covariates_important_huge\traffic_landuse_pop.gdb"
# point sources
env.workspace = r"E:\GIS 12_06_15 backup\CAPS_covariates_important_huge\Point_sources.gdb"
# special
# env.workspace = r"E:\GIS 12_06_15 backup\CAPS_covariates_important_huge\special.gdb"

# Select the shapefile containing the polygons to use as boundaries
# for zonal statistics
watershedFeat = r"E:\GIS 12_06_15 backup\Raster GIS\qing_200m_cells_proj_id.shp"

# watershedFeat = r"C:\Users\hugh\Desktop\GISProject_NoSpace\ACE_1km_shp\ACE_polygon_noZ.shp"

# Select output folder for saving the output - zonal tables (.dbf files)
outDir = "C:\\Users\\hugh\\Desktop\\qing_LUR\\"

# Something goes wrong with this script during use, perhaps with the
# temporary files.  No error messages are given.  The "print" statements
# inserted within the script keep track of where to restart.  Replace the '0'
# in the "for" statement with the most recently printed integer (printing of
# the variable 'ndx').

x = arcpy.ListRasters()
# the "0" can be replaced by the most recent result of
# "print ndx" in order to restart where the code stopped
for raster in arcpy.ListRasters()[0:]:
   print raster 
   ndx = x.index(raster)
   print ndx
   outTable = outDir + raster + ".dbf"
   arcpy.gp.ZonalStatisticsAsTable_sa(watershedFeat,
#      "Name", # Select an attribute in the shape file to identify polygons, 
      "PageNumber", # this attribute for 200m grid cell
	  raster,
      outTable,
      "DATA", "MEAN") # you might wanna remove "NODATA" so you can get all values even for raster like indus 1000. With nodata included, any NA cell in the polygon will yield NA for the polygon

   
 

# arcpy.CheckInExtension("Spatial")