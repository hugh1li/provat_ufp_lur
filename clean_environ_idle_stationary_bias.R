library(tidyverse)

# first check if my FMPS data vibration cleaned
fmps_check <- read_rds("data/refined_data/FMPS_winter_ellis.rds")

# from size bin 12.4 to 393.3 (corrected size bins, from column 7 to 28), more than 3 occurrences of 0s in middle size bins then delete the row.
# vibratinon
FMPS_winter4 <- fmps_check %>% mutate(diagnostics = rowSums(.[, c(7:28)] == 0.0)) %>% filter(diagnostics < 4) %>% select(-diagnostics)

write_rds(FMPS_winter4, "data/refined_data/Final_FMPS_winter_ellis.rds")

# now the file you sent to provat
sent_provat <- read_csv("FMPS_with_DT_EST.csv")
summary(sent_provat)
# ok, you see a lot less data


# conclude ----------------------------------------------------------------

# i am fine with my FMPS data (sending to provat). I am pretty sure it should be cleaned. Some of current repo not vibration cleanned. But check 564138/612088 = 92% data retained after filtering. I should be fine (and we are only using samples of data, > xx days).
# the key is to find out how I get FMPS_with_DT_EST; I am not doing that in ACE_SR
# the loss of fmps_with_dt, might be i did not create repo in the beginning.

# mapping clean environment -----------------------------------------------


