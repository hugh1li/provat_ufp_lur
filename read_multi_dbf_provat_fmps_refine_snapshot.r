# this one for provat 50-100-200 all CACES boxes

# note
# 1. I replaced NA values with 25 (smallest cell area)

require(tidyverse)
require(foreign)

readDBF <- function(file){
  df <- read.dbf(file, as.is=FALSE)
  df$fileName <- file
  return(df)
}


fileID1 <- list.files(path =  "arcgis_zonal/provat_lur_200m/", pattern="*\\.dbf$")
file.names1 <- paste0("arcgis_zonal/provat_lur_200m/", fileID1)

combinedData1 <- file.names1 %>% map_dfr(readDBF) %>% dplyr::rename(ID = PageNumber) %>% mutate(fileName = tools::file_path_sans_ext(basename(fileName)))

combinedData <- combinedData1

Data_cleaned <- combinedData %>% select(ID, MEAN, fileName) %>% tidyr::spread(key = fileName, value = MEAN)

# get 200m ID ---------------------------------------------------

# found ellis was using dn, not dn/dlog...
qing_id <- read_rds("data/refined_data/all_fmps.rds") %>% mutate(UFP = (F8.06 + F9.31 + F10.8 + F12.4 + F14.3 + F16.5 + F19.1 + F22.1 + F25.5 + F29.4 + F34+ F39.2 + F45.3 + F52.3 + F60.4 + F69.8 + F92.5)/16) %>% select(ID = GRID200MID, UFP)

qing_id_01 <- read_rds("data/refined_data/all_fmps.rds") %>% mutate(UFP = (F8.06 + F9.31 + F10.8 + F12.4 + F14.3 + F16.5 + F19.1 + F22.1 + F25.5 + F29.4 + F34+ F39.2 + F45.3 + F52.3 + F60.4 + F69.8 + F92.5)/16) %>% select(DateTime, ID = GRID200MID, UFP) %>% mutate(DateTime = lubridate::with_tz(DateTime, tzone = 'EST'))

Data_cleaned_filtered <- Data_cleaned %>% inner_join(qing_id, by = "ID")


# check where NA occurred --------------------------------------------------
temp = map_df(Data_cleaned_filtered, ~sum(is.na(.))) 
temp1 <- temp %>% gather()
View(temp1)

# 1. NA all in land use columns, replaced with 25 (the smallest cell area)
Data_cleaned_filtered[is.na(Data_cleaned_filtered)] <- 25

# 2. multiple the buffer areas
buffer_multiply <- readxl::read_excel("buffer_multiply.xlsx")
buffer <- buffer_multiply$buffer_adj
# 267 the last ind column.
ind <- Data_cleaned_filtered[, c(1:267)] %>% dplyr::rename(DISTALL = DISTALLNZ, DISTMAJ = DISTMAJADJ) %>% sweep(2, buffer, FUN = "*")
# 3. create the new variables

indf <- ind %>% mutate(DISTINVALL = 1/DISTALL, DISTINVMAJ = 1/DISTMAJ, DISTINVALL2 = DISTINVALL^2,  DISTINVMAJ2 =  DISTINVMAJ^2, ALLAADT_DIS = ALLAADT * DISTINVALL, ALLAADT_DIS2 = ALLAADT * DISTINVALL2, MAJAADT_DIS = MAJAADT * DISTINVMAJ, MAJAADT_DIS2 = MAJAADT * DISTINVMAJ2, ALLDIESAADT_DIS = ALLDIESAADT *DISTINVALL, ALLDIESAADT_DIS2 = ALLDIESAADT *DISTINVALL2, MAJDIESAADT_DIS = MAJDIESAADT * DISTINVMAJ, MAJDIESAADT_DIS2 = MAJDIESAADT * DISTINVMAJ2) %>% select(-DISTALL, -DISTMAJ) %>%  dplyr::rename(Elevation = elevMOD) %>% mutate(EucDistinv_As = 1/EucDist_As, EucDistinv_Cl = 1/EucDist_Cl, EucDistinv_Co = 1/EucDist_Co, EucDistinv_Cr = 1/EucDist_Cr, EucDistinv_Ni = 1/EucDist_Ni, EucDistinv_PM = 1/EucDist_PM, EucDistinv_Sb = 1/EucDist_Sb, EucDistinv2_Sb = EucDistinv_Sb ^2, EucDistinv2_PM = EucDistinv_PM^2, EucDistinv2_As = EucDistinv_As^2, EucDistinv2_Ni = EucDistinv_Ni^2, EucDistinv2_Cr = EucDistinv_Cr ^2, EucDistinv2_Cl = EucDistinv_Cl^2, EucDistinv2_Co = EucDistinv_Co ^ 2) %>% mutate(Allo_Dist_Sb = EucAllo_Sb * EucDistinv_Sb, Allo_Dist2_Sb = EucAllo_Sb * EucDistinv2_Sb, Allo_Dist_PM = EucAllo_PM * EucDistinv_PM, Allo_Dist2_PM = EucAllo_PM * EucDistinv2_PM, Allo_Dist_Ni = EucAllo_Ni * EucDistinv_Ni, Allo_Dist2_Ni = EucAllo_Ni * EucDistinv2_Ni,
Allo_Dist_Cr = EucAllo_Cr * EucDistinv_Cr, Allo_Dist2_Cr = EucAllo_Cr * EucDistinv2_Cr,
Allo_Dist_Co = EucAllo_Co * EucDistinv_Co, Allo_Dist2_Co = EucAllo_Co * EucDistinv2_Co,
Allo_Dist_Cl = EucAllo_Cl * EucDistinv_Cl, Allo_Dist2_Cl = EucAllo_Cl * EucDistinv2_Cl,
Allo_Dist_As = EucAllo_As * EucDistinv_As, Allo_Dist2_As = EucAllo_As * EucDistinv2_As) %>% select(-EucDist_As, -EucDist_Sb, -EucDist_PM, -EucDist_Co, -EucDist_Cl, -EucDist_Ni, -EucDist_Cr)

depf <- Data_cleaned_filtered[, c(268: dim(Data_cleaned_filtered)[2])]

depf1 <- as.tibble(depf)

indf1 <- distinct(indf) # Ok, distinct 200m ID in total 920, I don't know why the initial one Data_cleaned has 925 distincts...

write_csv(indf1, "LUR_ind_input.csv")

write_csv(qing_id, 'LUR_dep.csv')

# provat UFP
write.csv(qing_id_01, 'FMPS_with_DT_EST.csv')

