# note
# 1. I replaced NA values with 25 (smallest cell area)

require(tidyverse)
require(foreign)

readDBF <- function(file){
  df <- read.dbf(file, as.is=FALSE)
  df$fileName <- file
  return(df)
}


fileID1 <- list.files(path =  "arcgis_zonal_fmps_and_allcity200_zonal /city_all_200/",pattern="*\\.dbf$")
file.names1 <- paste0("arcgis_zonal_fmps_and_allcity200_zonal /city_all_200/", fileID1)

#luagri100 no data, error
file.names2 <- file.names1[!file.names1 %in% c('arcgis_zonal_fmps_and_allcity200_zonal /city_all_200/LUAGRI100.dbf', "arcgis_zonal_fmps_and_allcity200_zonal /city_all_200/LUAGRI300.dbf")]
combinedData <- file.names2 %>% map_dfr(readDBF) %>% dplyr::rename(ID = PageNumber) %>% mutate(fileName = tools::file_path_sans_ext(basename(fileName)))

Data_cleaned <- combinedData %>% select(ID, MEAN, fileName) %>% tidyr::spread(key = fileName, value = MEAN)


# check where NA occurred --------------------------------------------------
temp = map_df(Data_cleaned, ~sum(is.na(.))) 
temp1 <- temp %>% gather()

# 1. NA all in land use columns, replaced with 25 (the smallest cell area)
Data_cleaned[is.na(Data_cleaned)] <- 25

# 2. multiple the buffer areas
buffer_multiply <- readxl::read_excel("provat PointDe_PM extraction 033019/buffer_justPointDePM.xlsx") # remove the luagri100 and luagri300.

buffer <- buffer_multiply$buffer_adj

# 265 the last ind column. 
ind <- Data_cleaned %>% select(ID, EucAllo_PM, EucDist_PM, Idw_PM_1, Idw_PM_2, PointDe_NEI_1000, PointDe_NEI_10000, PointDe_NEI_1500, PointDe_NEI_15000, PointDe_NEI_20000, PointDe_NEI_3000, PointDe_NEI_30000, PointDe_NEI_5000, PointDe_NEI_7500, PointDe_NEI_PM_1000, PointDe_NEI_PM_10000, PointDe_NEI_PM_1500, PointDe_NEI_PM_15000, PointDe_NEI_PM_20000, PointDe_NEI_PM_3000, PointDe_NEI_PM_30000, PointDe_NEI_PM_5000, PointDe_NEI_PM_7500, PointDe_NEI_PM_Popu_1000, PointDe_NEI_PM_Popu_10000, PointDe_NEI_PM_Popu_1500, PointDe_NEI_PM_Popu_15000, PointDe_NEI_PM_Popu_20000, PointDe_NEI_PM_Popu_3000, PointDe_NEI_PM_Popu_30000, PointDe_NEI_PM_Popu_5000, PointDe_NEI_PM_Popu_7500) %>% sweep(2, buffer[-1], FUN = "*")
# 3. create the new variables

indf <- ind %>% mutate(EucDistinv_As = 1/EucDist_As, EucDistinv_Cl = 1/EucDist_Cl, EucDistinv_Co = 1/EucDist_Co, EucDistinv_Cr = 1/EucDist_Cr, EucDistinv_Ni = 1/EucDist_Ni, EucDistinv_PM = 1/EucDist_PM, EucDistinv_Sb = 1/EucDist_Sb, EucDistinv2_Sb = EucDistinv_Sb ^2, EucDistinv2_PM = EucDistinv_PM^2, EucDistinv2_As = EucDistinv_As^2, EucDistinv2_Ni = EucDistinv_Ni^2, EucDistinv2_Cr = EucDistinv_Cr ^2, EucDistinv2_Cl = EucDistinv_Cl^2, EucDistinv2_Co = EucDistinv_Co ^ 2) %>% mutate(Allo_Dist_Sb = EucAllo_Sb * EucDistinv_Sb, Allo_Dist2_Sb = EucAllo_Sb * EucDistinv2_Sb, Allo_Dist_PM = EucAllo_PM * EucDistinv_PM, Allo_Dist2_PM = EucAllo_PM * EucDistinv2_PM, Allo_Dist_Ni = EucAllo_Ni * EucDistinv_Ni, Allo_Dist2_Ni = EucAllo_Ni * EucDistinv2_Ni,
Allo_Dist_Cr = EucAllo_Cr * EucDistinv_Cr, Allo_Dist2_Cr = EucAllo_Cr * EucDistinv2_Cr,
Allo_Dist_Co = EucAllo_Co * EucDistinv_Co, Allo_Dist2_Co = EucAllo_Co * EucDistinv2_Co,
Allo_Dist_Cl = EucAllo_Cl * EucDistinv_Cl, Allo_Dist2_Cl = EucAllo_Cl * EucDistinv2_Cl,
Allo_Dist_As = EucAllo_As * EucDistinv_As, Allo_Dist2_As = EucAllo_As * EucDistinv2_As) %>% select(-EucDist_As, -EucDist_Sb, -EucDist_PM, -EucDist_Co, -EucDist_Cl, -EucDist_Ni, -EucDist_Cr)

# depf <- Data_cleaned_filtered[, c(268: dim(Data_cleaned_filtered)[2])]

# add ID back
df <- bind_cols(Data_cleaned[1] ,indf)

write_csv(df, "Porvat77_more_sites_LUR_input.csv")
