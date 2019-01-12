library(tidyverse)
library(leaflet)

# first check if my FMPS data vibration cleaned/
fmps_check <- read_rds("data/refined_data/FMPS_winter_ellis.rds")

# from size bin 12.4 to 393.3 (corrected size bins, from column 7 to 28), more than 3 occurrences of 0s in middle size bins then delete the row.
# vibratinon
FMPS_winter4 <- fmps_check %>% mutate(diagnostics = rowSums(.[, c(7:28)] == 0.0)) %>% filter(diagnostics < 4) %>% select(-diagnostics)

write_rds(FMPS_winter4, "data/refined_data/Final_FMPS_winter_ellis.rds")

# so I just cleaned them and the FMPS_winter_ellis is vibration fixed.


# now the file you sent to provat
sent_provat <- read_csv("FMPS_with_DT_EST.csv")
summary(sent_provat)
# ok, you see a lot less data


# conclude ----------------------------------------------------------------

# i am fine with my FMPS data (sending to provat). I am pretty sure it should be cleaned. Some of current repo not vibration cleanned. But check 564138/612088 = 92% data retained after filtering. I should be fine (and we are only using samples of data, > xx days).
# the key is to find out how I get FMPS_with_DT_EST; I am not doing that in ACE_SR
# the loss of fmps_with_dt, might be i did not create repo in the beginning.

# mapping clean environment -----------------------------------------------
# first get FMPS
FMPS_bias_check <- read_rds("data/refined_data/Final_FMPS_winter_ellis_dn.rds")
# then GPS
GPS <- read_rds('data/refined_data/WinterGPS_EllisOnly.rds')

# join them

GPS_with_pn <- GPS %>% inner_join(FMPS_bias_check) %>% mutate(Total_PN = rowSums(.[8:37])) %>% select(-c(F6.04:F856.8)) # not my total_pn here does not consider 1st two columns

GPS_with_pn_idling <- GPS_with_pn %>% filter(Speed < 2)
  
leaflet(data = GPS_with_pn_idling[1000:2000, ]) %>% addTiles() %>% addMarkers(~Lon, ~Lat, popup = ~as.character(Speed)) # not super useful


# target 1 in schenley park to downtown----
target1 <- GPS_with_pn[0:3000, ]
t_plot1 <- ggplot(target1) + geom_point( aes(x = DateTime, y = Total_PN), alpha = 0.1) + scale_y_continuous(limits = c(0, 75000)) + labs(y = 'Total PN (#/cm3)', title = '01/11/18')  
t_plot2 <- ggplot(target1) + geom_point(aes(DateTime, y = Speed), alpha = 0.1) + labs(y = 'Speed (m/s)')
cowplot::plot_grid(t_plot1, t_plot2, align = 'v', nrow = 2)
ggsave('idling stationary bias/CMU-downtown Speed PN time series.pdf')

# target 1 

t_map1 <- leaflet(data = target1) %>% addTiles() %>% addMarkers(~Lon, ~Lat, popup = paste("DateTime: ", target1$DateTime, "<br>", 
                              "Speed: ", target1$Speed, "<br>",
                              'PN: ', target1$Total_PN))

# save to widget 
library(htmlwidgets)
saveWidget(t_map1, file="CMU-downtown.html")


# all schenley park data ------
# now choose points fall into the schenley park
schenley_park <- GPS_with_pn %>% filter(Lat > 40.430522, Lat < 40.437881, Lon < -79.932090, Lon > -79.947961) %>% mutate(Date = lubridate::date(DateTime))

write_csv(schenley_park, 'idling stationary bias/schenley_park.csv')

# what are the days?
unique(schenley_park$Date)

# target 2 ----
t_plot1 <- schenley_park %>% filter(as.character(Date) == '2018-01-17') %>% ggplot() + geom_point( aes(x = DateTime, y = Total_PN), alpha = 0.5)  + labs(y = 'Total PN (#/cm3)')  + scale_y_continuous(limits = c(0, 60000))
t_plot2 <- schenley_park %>% filter(as.character(Date) == '2018-01-17') %>% ggplot() + geom_point(aes(DateTime, y = Speed), alpha = 0.5) + labs(y = 'Speed (m/s)')

cowplot::plot_grid(t_plot1, t_plot2, align = 'v', nrow = 2)
# ggsave('idling stationary bias/CMU-downtown Speed PN time series.pdf')

# target 1 
target <- schenley_park %>% filter(as.character(Date) == '2018-01-17')
t_map1 <-  leaflet(data = target) %>% addTiles() %>% addMarkers(~Lon, ~Lat, popup = paste("DateTime: ", target$DateTime, "<br>", 
                                                                                          "Speed: ", target$Speed, "<br>",
                                                                                          'PN: ', target$Total_PN))

t_map1

# save to widget 
library(htmlwidgets)
# saveWidget(t_map1, file="CMU-downtown.html")


# my all schenley data ----------------------------------------------------

all_schenley <-  leaflet(data = schenley_park) %>% addTiles() %>% addMarkers(~Lon, ~Lat, popup = paste("DateTime: ", schenley_park$DateTime, "<br>", 
                                                                                          "Speed: ", schenley_park$Speed, "<br>",
                                                                                          'PN: ', schenley_park$Total_PN))

saveWidget(all_schenley, file="Schenley_park.html")


