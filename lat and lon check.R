# lat and long check
library(tidyverse)
provat <- readxl::read_xlsx("data/lat lon/Mobile_UFP_site_ID_provat_sent_920.xlsx")
anyDuplicated(provat$ID)
# 0

new_925 <- read_csv("data/lat lon/provat_lat_lon.csv")
anyDuplicated(new_925$PageNumber)
n_distinct(new_925$PageNumber)
# 0

# the right one FMPS_DST 
right <- read_csv("FMPS_with_DT_EST.csv")
anyDuplicated(right$ID) 
# 2 

What are they?
n_distinct(right$ID)

# so i guess from 925 to 920 is due to some cells no data coz all cells were based on GPS

provat_02 <- new_925 %>% select(ID  = PageNumber, lat, lon) %>% semi_join(provat['ID'])

write_csv(provat_02, 'provat_lat_lon.csv')
