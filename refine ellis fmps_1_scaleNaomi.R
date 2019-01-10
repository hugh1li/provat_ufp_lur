library(tidyverse)
library(rgdal)
library(lubridate)

# gpx read
# I see backup folder
# i think they are the same, and i just load the files in the normal folder (and assume backup maximum size == the normal one)

#1.1 GPS----
# GPS speed units in m/s!
setwd('data/FMPS_winter_ellis/gps_raw/')
GPS_raw <- list.files(pattern = ".gpx")
GPS_transform <- function(x){
  layers <- ogrListLayers("20180111-162901-0010307-132351.gpx")
  x %>% readOGR(layer = layers[5], stringsAsFactors = FALSE) %>% as_tibble() %>%
    select(Elev = ele, DateTime = time, Speed = badelf_speed, Lon = coords.x1, Lat = coords.x2) %>%
    mutate(DateTime = parse_date_time(DateTime, "%Y/%m/%d %H:%M:%Sz"))
}

GPS_UTC <- GPS_raw %>% purrr::map_df(GPS_transform)
GPS_EST <- GPS_UTC %>% mutate(DateTime = with_tz(DateTime, tz = "EST"))
# fix some weird speed issues or weird GPS latitudes, lon.
GPS_EST_f <- GPS_EST %>% filter(Speed < 200, Lat > 40, Lat < 41, Lon > -81, Lon < -79, year(DateTime) %in% c(2016, 2017, 2018), Elev > 0) %>% distinct(DateTime, .keep_all = TRUE)
# ?change speed limit (17 m/s ~ 100), nope, coz you can jsut explain it's the GPS accuracy, and it makes me lost 4.6 hours of data (pretty much they are just stationary data).

# second(GPS_EST_f$DateTime[1]), don't need to round
#  need to remove the duplicates
GPS_EST_f1 <- distinct(GPS_EST_f, DateTime, .keep_all = TRUE)
GPS_EST_f2 <- distinct(GPS_EST_f)
#well, I will adopt the f1 one (i saw several numbers missing in f2 is because that second is in previous rows)
setwd("../../..")
write_rds(GPS_EST_f2, 'data/refined_data/WinterGPS.rds')
GPS_shapefile <- as.data.frame(GPS_EST_f2)
coordinates(GPS_shapefile) <- ~Lon + Lat
proj4string(GPS_shapefile) <- "+proj=longlat +datum=WGS84" 

write_rds(GPS_EST_f2, 'data/refined_data/WinterGPS.rds')
write_csv(GPS_EST_f2, 'data/refined_data/WinterGPS.csv')
# Write to shapefile to verify my sp method is right
writeOGR(obj = GPS_shapefile, dsn = "data/gps_shape", layer = "GPS_new_winter", driver = 'ESRI Shapefile')

# 1.2 fmps extract and recal----
# i eyeball every file, removed two trip files. lul
# MY PREVIOUS experience
# check how many files have two trips inside. Then you have to rename files

# then FMPS, I see txt and fmps specific file. I think i can just use txt. coz they correspond one to one (FMPS file)
setwd("data/FMPS_winter_ellis/fmps_raw/")
fmps_files <- list.files(pattern ='*.txt')
all_lines <- purrr::map(fmps_files, ~read_lines(.x, n_max = 2))
Alldates <- purrr::map(seq(length(fmps_files)), ~all_lines[[.]][str_detect(all_lines[[.]], pattern = "^Date")])

# use this one, FMPS change the date time for manual one trip file.
FMPS_timeToDatetime <- function(i){
  coltype <- paste(c("-", rep("d", 32), "-"), collapse = "") # Ellis's files total concentration directly follows the last size bin + datetime column
  # though i was not quite sure why only ignore one column after rep(d, 32)
  test <- read_tsv(fmps_files[i], col_names = FALSE, col_types = coltype, skip = 15) # some only need to skip 14 lines, but one more is fine
  test_Dates <- Alldates[[i]]
  test_dt <- mdy_hms(test_Dates, tz = "EST")
  test$DateTime <- seq.POSIXt(from = test_dt + seconds(1), by = "sec", length.out =  nrow(test))
  # mdy_hms('01-02-2018 23:59:59') + seconds(1)
  # "2018-01-03 UTC" # don't need to worry about becoming another day
  test
}

FMPS_winter <- seq(1:length(fmps_files)) %>% purrr::map_df(FMPS_timeToDatetime) # with stationary data as well.

FMPS_winter1 <- select(FMPS_winter, DateTime, everything())
FMPS_correctSize_names <- unlist(str_split("DateTime,F6.04,F6.98,F8.06,F9.31,F10.8,F12.4,F14.3,F16.5,F19.1,F22.1,F25.5,F29.4,F34,F39.2,F45.3,F52.3,F60.4,F69.8,F92.5,F114.1,F138.9,F167.6,F200.8,F239.1,F283.3,F334.4,F393.3,F461.5,F540,F630.8,F735.8,F856.8,", pattern =","))[-34] # -35 is for removing that blank

names(FMPS_winter1) <- FMPS_correctSize_names
# reallign because retention in sampling lines
FMPS_winter2 <- FMPS_winter1 %>% mutate(DateTime = DateTime - seconds(7))

setwd("../../..")
# resize and calibrate
FMPS_resize <- read_csv("data/FMPS resize.csv", 
                        col_types = cols(Intercept = col_double()))
FMPS_winter3 <- FMPS_winter2 # make a copy here...

for(i in seq(32)){
  FMPS_winter3[,i+1] = FMPS_winter3[,i+1]*FMPS_resize$Slope[i] + FMPS_resize$Intercept[i] # naomi paper correction
}

write_rds(FMPS_winter3, "data/refined_data/FMPS_winter_ellis.rds")
