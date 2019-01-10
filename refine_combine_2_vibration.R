# deal with vibration in new FMPS data
# combined with previous mob
# join with GPS

# from size bin 12.4 to 393.3 (corrected size bins, from column 7 to 28), more than 3 occurrences of 0s in middle size bins then delete the row.
# vibratinon
FMPS_winter4 <- FMPS_winter3 %>% mutate(diagnostics = rowSums(.[, c(7:28)] == 0.0)) %>% filter(diagnostics < 4) %>% select(-diagnostics)

# GPS to put in the arcgis to get grid box IDs
library(sp)
# import previous box shapefiles
boxes_50 <- readOGR(dsn = "/Users/hugh/Box Sync/from_dropbox/ACE hugh/ACE R/R arcgis map/Boxes_shapefile/Boxes_50m.shp")
boxes_100 <- readOGR(dsn = "/Users/hugh/Box Sync/from_dropbox/ACE hugh/ACE R/R arcgis map/Boxes_shapefile/Boxes_100m.shp")
boxes_200 <- readOGR(dsn = "/Users/hugh/Box Sync/from_dropbox/ACE hugh/ACE R/R arcgis map/Boxes_shapefile/Boxes_200m.shp")

# I think I kinda gave up this one coz kind slow importing such a large file...

GPS_shapefile

# join with GPS
FMPS_GPS_new <- GPS_EST_f2 %>% inner_join(FMPS_winter4)

