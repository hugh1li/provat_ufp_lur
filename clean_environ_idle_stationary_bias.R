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
FMPS_bias_check <- read_rds("data/refined_data/Final_FMPS_winter_ellis.rds")
# then GPS
GPS <- read_rds('data/refined_data/WinterGPS_EllisOnly.rds')

# join them

GPS_with_pn <- GPS %>% inner_join(FMPS_bias_check) %>% mutate(Total_PN = rowSums(.[8:37])/16) %>% select(-c(F6.04:F856.8)) # not my total_pn here does not consider 1st two columns

GPS_with_pn_idling <- GPS_with_pn %>% filter(Speed < 2)
  
leaflet(data = GPS_with_pn_idling[1000:2000, ]) %>% addTiles() %>% addMarkers(~Lon, ~Lat, popup = ~as.character(Speed)) # not super useful


# target 1 in schenley park
target1 <- GPS_with_pn[0:3000, ]
t_plot1 <- ggplot(target1) + geom_point( aes(x = DateTime, y = Total_PN), alpha = 0.5) + scale_y_continuous(limits = c(0, 7000)) + labs(y = 'Total PN (#/cm3)')
t_plot2 <- ggplot(target1) + geom_point(aes(DateTime, y = Speed), alpha = 0.5) + labs(y = 'Speed (m/s)')
cowplot::plot_grid(t_plot1, t_plot2, align = 'v', nrow = 2)
ggsave('CMU-downtown Speed PN time series.pdf')

# target 1

t_map1 <- leaflet(data = target1) %>% addTiles() %>% addMarkers(~Lon, ~Lat, popup = paste("DateTime: ", target1$DateTime, "<br>", 
                              "Speed: ", target1$Speed, "<br>",
                              'PN: ', target1$Total_PN))

# save to widget 
library(htmlwidgets)
saveWidget(t_map1, file="CMU-downtown.html")
