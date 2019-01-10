# first import the shapefile with 50-100-200 IDs
# ellis_new_fmps_gridID
ellis_new_fmps_gridID <- read_csv("data/refined_data/ellis_new_FMPS_gridID.csv")

# join with the FMPS data
new_fmps <- read_rds("data/refined_data/FMPS_winter_ellis.rds")


ellis_new_fmps_gridID_01 <- ellis_new_fmps_gridID %>% select(-OBJECTID, -Join_Count, -TARGET_FID) %>%  inner_join(new_fmps) %>% rename(GRID50MID = Grid50mID, GRID100MID = Grid100mID, GRID200MID = Grid200mID) 

# tranform dn to dn/dlogdp
ellis_new_fmps_gridID_02 <- ellis_new_fmps_gridID_01 %>% mutate_at(vars(starts_with('F')), funs(.*16))

# did it worked.
check <- ellis_new_fmps_gridID_02[1, ] %>% bind_rows(ellis_new_fmps_gridID_01[ 1,])
# yup

all_fmps <- ellis_new_fmps_gridID_02 %>% bind_rows(Mob_to_add_01) %>% filter(!is.na(F6.04)) # EST auto transformed to be UTC
write_rds(all_fmps, "data/refined_data/all_fmps.rds")

all_fmps_01 <- all_fmps %>% select(DateTime, Lon, Lat)
  
write_csv(all_fmps_01, 'data/refined_data/all_fmps_gps.csv')
