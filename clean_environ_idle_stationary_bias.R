library(tidyverse)

# first check if my FMPS data vibration cleaned
fmps_check <- read_rds("data/refined_data/FMPS_winter_ellis.rds")

# from size bin 12.4 to 393.3 (corrected size bins, from column 7 to 28), more than 3 occurrences of 0s in middle size bins then delete the row.
# vibratinon
FMPS_winter4 <- fmps_check %>% mutate(diagnostics = rowSums(.[, c(7:28)] == 0.0)) %>% filter(diagnostics < 4) %>% select(-diagnostics)
