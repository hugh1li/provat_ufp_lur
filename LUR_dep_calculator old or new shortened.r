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


fileID1 <- list.files(path =  "arcgis_zonal_fmps_and_allcity200_zonal /city_all_200/", pattern="*\\.dbf$")
file.names1 <- paste0("arcgis_zonal_fmps_and_allcity200_zonal /city_all_200/", fileID1)

combinedData1 <- file.names1 %>% map_dfr(readDBF) %>% dplyr::rename(ID = PageNumber) %>% mutate(fileName = tools::file_path_sans_ext(basename(fileName)))

combinedData <- combinedData1

Data_cleaned <- combinedData %>% select(ID, MEAN, fileName) %>% tidyr::spread(key = fileName, value = MEAN)

# need to extract restaurant only data
Data_cleaned_filtered <- Data_cleaned[c(1:17, 32:66, 177:228)]

# check where NA occurred --------------------------------------------------
temp = map_df(Data_cleaned_filtered, ~sum(is.na(.))) 
temp1 <- temp %>% gather()
View(temp1)

# 1. NA all in land use columns, replaced with 25 (the smallest cell area)
Data_cleaned_filtered[is.na(Data_cleaned_filtered)] <- 25

# 2. multiple the buffer areas

buffer_multiply <- readxl::read_excel("buffer_multiply_provat_only.xlsx")

buffer <- buffer_multiply$buffer_adj

# check if I am multiplying in right way
buffer_multiply$names  == names(Data_cleaned_filtered)

ind <- Data_cleaned_filtered %>% dplyr::rename(DISTALL = DISTALLNZ, DISTMAJ = DISTMAJADJ) %>% sweep(2, buffer, FUN = "*")
# 3. create the new variables

indf <- ind %>% mutate(DISTINVALL = 1/DISTALL, DISTINVMAJ = 1/DISTMAJ, DISTINVALL2 = DISTINVALL^2,  DISTINVMAJ2 =  DISTINVMAJ^2, ALLAADT_DIS = ALLAADT * DISTINVALL, ALLAADT_DIS2 = ALLAADT * DISTINVALL2, MAJAADT_DIS = MAJAADT * DISTINVMAJ, MAJAADT_DIS2 = MAJAADT * DISTINVMAJ2, ALLDIESAADT_DIS = ALLDIESAADT *DISTINVALL, ALLDIESAADT_DIS2 = ALLDIESAADT *DISTINVALL2, MAJDIESAADT_DIS = MAJDIESAADT * DISTINVMAJ, MAJDIESAADT_DIS2 = MAJDIESAADT * DISTINVMAJ2) %>% select(-DISTALL, -DISTMAJ) %>%  dplyr::rename(Elevation = elevMOD)


write_rds(indf, 'data/city_all_200_covar.rds')


# create ind with point density -------------------------------------------


