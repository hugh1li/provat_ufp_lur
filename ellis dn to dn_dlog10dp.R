# ellis dn to dn/dlog10dp
# the dn file
FMPS_dn <- read_rds("data/refined_data/Final_FMPS_winter_ellis_dn.rds")
FMPS_dn_dlog10dp <- FMPS_dn %>% mutate_if(is.numeric, function(x){x/16})

write_rds(FMPS_dn_dlog10dp, 'data/refined_data/Final_FMPS_winter_ellis_dn_dlog10dp.rds')
