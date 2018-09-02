library(lubridate)

Mob_tempcorrect50 <- read_rds('/Users/hugh/Box Sync/from_dropbox/ACE hugh/ACE R/ACE final data/R database/after join/Mob_tempcorrect50.rds')
Mob_to_add <- Mob_tempcorrect50 %>% select(Elev, DateTime, Speed, Lon, Lat,  GRID50MID, GRID100MID, GRID200MID, F6.04:F856.8)

# only winter December, 1, 2
Mob_to_add_01 <- Mob_to_add %>% filter(month(DateTime) %in% c(1, 2, 12))

write_csv(Mob_to_add_01, 'data/refined_data/Mob_to_add_CACES.csv')
