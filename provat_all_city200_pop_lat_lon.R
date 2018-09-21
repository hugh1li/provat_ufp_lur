library(tidyverse)

# get pop lat and lon
pop <- read_csv('data/provat_his_covar0920_based_on_qing/qing_pop.csv')
pop_01 <- pop %>% select( PageNumber, Pop = SUM_Area_pop)

# lat and lon (need arcgis calculation)
lat_lon <- readxl::read_xlsx('data/provat_his_covar0920_based_on_qing/all_city_200_lat_lon.xlsx')

# then the raster calculator refined data
indf1 <- indf %>% rename(PageNumber = ID) %>% as.tibble()

# join them!
provat_0920 <- lat_lon %>% inner_join(pop_01) %>% inner_join(indf1) %>% rename(Polygon200ID = PageNumber, long = long_cal, lat = lat_cal)

summary(provat_0920)
write_csv(provat_0920, 'data/provat_0920.csv')
