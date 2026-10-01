# Copyright (c) 2023 Honorata Bogusz
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Dependency: European country exhibits and appendix coverage/count diagnostics


{
rm(list=ls())
gc()
options(timeout = 600, scipen=999, digits=2)

requiredPackages = c("dplyr", "haven", "stringr", "countrycode", "purrr")
missingPackages <- requiredPackages[!vapply(requiredPackages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missingPackages)) stop("Missing R packages: ", paste(missingPackages, collapse = ", "))
invisible(lapply(requiredPackages, library, character.only = TRUE))

rm(list=ls())
gc()


source_eu_lfs <- "../../data/raw/eu_lfs/"




files <- list.files(path = source_eu_lfs, pattern = "*.csv", full.names = T)


files <- files[files != paste0(source_eu_lfs, "DK2015_y.csv")]
files <- files[files != paste0(source_eu_lfs, "DK2016_y.csv")]
files <- files[files != paste0(source_eu_lfs, "DK2017_y.csv")]
files <- files[files != paste0(source_eu_lfs, "DK2018_y.csv")]
files <- files[files != paste0(source_eu_lfs, "DK2019_y.csv")]

files <- files[files != paste0(source_eu_lfs, "CH2015_y.csv")]
files <- files[files != paste0(source_eu_lfs, "CH2016_y.csv")]
files <- files[files != paste0(source_eu_lfs, "CH2017_y.csv")]
files <- files[files != paste0(source_eu_lfs, "CH2018_y.csv")]
files <- files[files != paste0(source_eu_lfs, "CH2019_y.csv")]

files <- files[files != paste0(source_eu_lfs, "IS2015_y.csv")]
files <- files[files != paste0(source_eu_lfs, "IS2016_y.csv")]
files <- files[files != paste0(source_eu_lfs, "IS2017_y.csv")]
files <- files[files != paste0(source_eu_lfs, "IS2018_y.csv")]
files <- files[files != paste0(source_eu_lfs, "IS2019_y.csv")]

files <- files[files != paste0(source_eu_lfs, "FI2015_y.csv")]
files <- files[files != paste0(source_eu_lfs, "FI2016_y.csv")]
files <- files[files != paste0(source_eu_lfs, "FI2017_y.csv")]
files <- files[files != paste0(source_eu_lfs, "FI2018_y.csv")]
files <- files[files != paste0(source_eu_lfs, "FI2019_y.csv")]

files <- files[files != paste0(source_eu_lfs, "SE2015_y.csv")]
files <- files[files != paste0(source_eu_lfs, "SE2016_y.csv")]
files <- files[files != paste0(source_eu_lfs, "SE2017_y.csv")]
files <- files[files != paste0(source_eu_lfs, "SE2018_y.csv")]
files <- files[files != paste0(source_eu_lfs, "SE2019_y.csv")]

source_rpa_ghs <- "../../data/raw/zaf_ghs/"


pop_2017 <- read.csv("../../data/raw/population_totals/P_Data_Extract_From_World_Development_Indicators/69e1ed3e-833e-444c-b892-93ce505de507_Data.csv")
pop_2017 <- pop_2017[,c("Country.Code", "X2017..YR2017.")]
colnames(pop_2017) <- c("COUNTRY", "pop_2017")
pop_2017 <- pop_2017[complete.cases(pop_2017), ]
pop_2017$pop_2017 <- as.numeric(pop_2017$pop_2017)


unempl_rates_eu_lfs <- read_dta("../../bld/data/unempl_rates_eu_lfs.dta")

dir.create("../../bld/data/Europe/", showWarnings = FALSE)
dir.create("../../bld/data/ZAF/", showWarnings = FALSE)

ids <- data.frame()
}


for (file in files){

  
  skip_to_next <- FALSE
  
  tryCatch(temp <- read.csv(file)[,c("COUNTRY", "YEAR", "REM", "QHHNUM", "HHSEQNUM", "HHSPOU", "HHLINK", 
                                     "AGE", "SEX", "DEGURBA", "REGION", "COEFF", "MARSTAT", "COUNTRYB")]
, error = function(e) {skip_to_next <<- TRUE})
  
  if(skip_to_next) { next } 
  
  if (unique(temp$COUNTRY=="GR")){
    temp$COUNTRY <- str_replace_all(temp$COUNTRY, "GR", "EL")
  }
  
  
  if (unique(temp$COUNTRY=="UK")){
    temp <- subset(temp, REGION != "N0")
  }
  
  temp$COUNTRY <- countrycode(temp$COUNTRY, origin = "eurostat", destination = "iso3c")
  
  temp <- merge(temp, pop_2017, by = "COUNTRY", all.x = T)
  
  
  counts <- temp
  c <- unique(counts$COUNTRY)
  copy <- temp
  
  counts <- counts %>% filter(HHLINK==1 | HHLINK==2)
  counts <- counts %>% filter(DEGURBA==1 | DEGURBA==2)
  counts$adult <- ifelse(counts$AGE>=22, 1, 0)
  counts <- counts %>% filter(AGE>=22)
  counts <- counts %>% 
    group_by(COUNTRY, QHHNUM, YEAR) %>%
    mutate(sum_adult = sum(adult))
  counts <- counts %>% filter(sum_adult==2)
  counts$age_65plus <- ifelse(counts$AGE>62, 1, 0)
  counts <- counts %>% 
    group_by(COUNTRY, QHHNUM, YEAR) %>%
    mutate(sum_age_65plus = sum(age_65plus))
  counts <- counts %>% 
    group_by(COUNTRY, QHHNUM, YEAR) %>%
    mutate(mean_sex = mean(SEX))
  counts$couple_type2 <- case_when(
    counts$mean_sex==1.5 ~ 0, # different-sex
    counts$mean_sex==1 | counts$mean_sex==2 ~ 1 # ssc
  )
  counts$ssc_65plus <- ifelse(counts$couple_type2==1 & counts$sum_age_65plus==1, 1, 0)
  counts <- counts[,c("YEAR", "ssc_65plus")]
  colnames(counts) <- c("year", "couple_type2")
  counts <- counts %>% 
    group_by(year) %>%
    mutate(mean_couple_type2 = mean(couple_type2))
  counts <- counts[,c("year", "mean_couple_type2")]
  colnames(counts) <- c("year", "couple_type2_65plus")
  counts <- unique(counts)
  year <- unique(counts$year)
  counts$country <- c
  write_dta(counts, paste0("../../bld/data/counts/Europe/", c, "_ssh_obs_yrs_old_age_", year, "_shares", ".dta"))
  rm(counts, c, year)
  

  temp$age_0_14 <- ifelse(temp$AGE>=0 & temp$AGE<17, 1, 0)
  temp$age_15_19 <- ifelse(temp$AGE==17, 1, 0)
  temp$age_20_64 <- ifelse(temp$AGE>=22 & temp$AGE<67, 1, 0)
  temp$age_65plus <- ifelse(temp$AGE>=67, 1, 0)
  
  temp <- temp %>%
    group_by(COUNTRY, QHHNUM, YEAR) %>%
    mutate(hh_age_0_14 = ifelse(age_0_14==1, sum(age_0_14==1), 0),
           hh_age_15_19 = ifelse(age_15_19==1, sum(age_15_19==1), 0),
           hh_age_20_64 = ifelse(age_20_64==1, sum(age_20_64==1), 0),
           hh_age_65plus = ifelse(age_65plus==1, sum(age_65plus==1), 0),
           hh_age_0_14 = max(hh_age_0_14),
           hh_age_15_19 = max(hh_age_15_19),
           hh_age_20_64 = max(hh_age_20_64),
           hh_age_65plus = max(hh_age_65plus),
           hh_age_0_14_d = ifelse(hh_age_0_14 > 0, 1, 0),
           hh_age_15_19_d = ifelse(hh_age_15_19 > 0, 1, 0),
           hh_age_20_64_d = ifelse(hh_age_20_64 > 0, 1, 0),
           hh_age_65plus_d = ifelse(hh_age_65plus > 0, 1, 0))
  
  temp$non_child <- ifelse(temp$age_0_14 == 1 & temp$HHLINK > 3 & temp$HHLINK < 9, 1, 0)
  
  temp <- temp %>%
    group_by(COUNTRY, QHHNUM, YEAR) %>%
    mutate(hh_age_0_14_nonch = sum(non_child==1),
           hh_age_0_14_nonch_d = ifelse(hh_age_0_14_nonch > 0, 1, 0))

  temp$age_0_14 <- NULL
  temp$age_15_19 <- NULL
  temp$age_20_64 <- NULL
  temp$age_65plus <- NULL
  temp$non_child <- NULL
  temp$hh_age_0_14_nonch <- NULL
  gc()
  

  temp <- temp %>% filter(HHLINK==1 | HHLINK==2)
  
  
  temp$adult <- ifelse(temp$AGE > 17 & temp$AGE < 67, 1, 0)
  temp <- temp %>% 
    group_by(COUNTRY, QHHNUM, YEAR) %>%
    mutate(sum_adult = sum(adult))
  
  temp <- temp %>% filter(sum_adult==1 | sum_adult==2)
  
  temp$single <- ifelse(temp$sum_adult==1, 1, 0)
  
  temp <- temp %>% filter(!(single==0 & sum_adult==1))
  
  
  if (unique(temp$COUNTRY=="FRA") | unique(temp$COUNTRY=="ESP")){
    temp$COEFF <- 1
  }
  
  temp$weight_adj <- temp$COEFF/sum(temp$COEFF)
  temp$weight_pop <- temp$weight_adj*temp$pop_2017
  temp <- transform(temp, weight_adj_hh = ave(temp$weight_adj, QHHNUM, FUN = sum),
                    weight_pop_hh = ave(temp$weight_pop, QHHNUM, FUN = sum))
  
  temp$COEFF <- NULL
  temp$weight_adj <- NULL
  temp$weight_pop <- NULL

  
  temp$mar_x <- ifelse(temp$MARSTAT == 2, 1, 0)
  temp$foreign_bp <- ifelse(temp$COUNTRYB != "000-OWN COUNTRY", 1, 0)
  
  
  temp <- temp %>% 
    group_by(COUNTRY, QHHNUM, YEAR) %>%
    mutate(mean_sex = ifelse(single==0, mean(SEX), NA),
           mean_married = mean(mar_x),
           max_foreign_bp = max(foreign_bp))
  
  
  
  temp$couple_type <- case_when(
    temp$mean_sex==1.5 ~ 1, # different-sex
    temp$mean_sex==1 ~ 2, # ssc men
    temp$mean_sex==2 ~ 3 # ssc women
  )
  
  
  temp$mean_sex <- NULL
  
  
  temp$married_couple <- ifelse(temp$mean_married==1, 1, 0)
  
  
  temp$foreign_born_any <- ifelse(temp$max_foreign_bp==1, 1, 0)
  
  
  
  temp <- temp %>% filter(HHLINK==1)
  
  
  temp$country_id <- temp$COUNTRY
  temp$COUNTRY <- NULL
  temp$world_region <- 1
  temp$year <- temp$YEAR
  temp$YEAR <- NULL
  temp$hh_id <- paste0(temp$country_id, temp$QHHNUM, temp$year)
  temp$quarter <- substr(temp$QHHNUM, 2, 2)
  temp$quarter <- as.numeric(temp$quarter)
  temp$month <- temp$REM
  
  temp$region <- as.character(temp$REGION)
  temp$REGION <- NULL
  temp$region <- paste0(temp$country_id, temp$region)
  
  temp$urban <- ifelse(temp$DEGURBA==1 | temp$DEGURBA==2, 1, 0)
  temp$DEGURBA <- NULL
  temp$ssm_direct <- NA
  
  temp <- temp[,c("country_id", "world_region", "hh_id", "QHHNUM",
                  "weight_adj_hh", "pop_2017", "weight_pop_hh",
                  "year", "quarter", "month",
                  "single", "couple_type",
                  "region", "urban",
                  "hh_age_0_14", "hh_age_15_19", "hh_age_20_64", "hh_age_65plus", 
                  "hh_age_0_14_d", "hh_age_15_19_d", "hh_age_20_64_d", "hh_age_65plus_d", "hh_age_0_14_nonch_d",
                  "ssm_direct", "married_couple", "foreign_born_any")]
  
  
  temp <- subset(temp, weight_adj_hh!=0)
  temp <- subset(temp, !is.na(weight_adj_hh))
  
  
  
  file <- substr(file, nchar(file)-11, nchar(file)-4)
  save(temp, file = paste0("../../bld/data/Europe/", file, "_filtered_hh.RData")) 
  rm(temp, file)
  gc()
}

rm(copy)


files_hh <- list.files(path="../../bld/data/Europe/", pattern="*_filtered_hh.RData", full.names = TRUE)
lfs <- files_hh %>%
  map_dfr(~ get(load(.)))
rm(files_hh)

lfs <- lfs[with(lfs, order(country_id, year, hh_id)),]
row.names(lfs) <- NULL

for (country in unique(lfs$country_id)){
  
  temp <- lfs %>% filter(country_id==country)
  write_dta(temp, paste0("../../bld/data/data_countries/", "data_hh_", temp$country_id, ".dta"))
  
}

rm(temp, lfs, country)




for (file in files){
  

  skip_to_next <- FALSE
  
  tryCatch(temp <- read.csv(file)[,c("COUNTRY", "YEAR", "QHHNUM", "HHSEQNUM", "HHLINK", "HHSPOU", 
                                     "AGE", "SEX", "HATLEV1D", "ILOSTAT", "COEFF", "REGION",
                                     "COUNTRYB", "NATIONAL", "STAPRO", "HWACTUAL", "HWACTUA2", "HWUSUAL", "ISCO3D", "ISCOPR3D")]  
           , error = function(e) {skip_to_next <<- TRUE})
  
  if(skip_to_next) { next } 
  
  
  if (unique(temp$COUNTRY=="GR")){
    temp$COUNTRY <- str_replace_all(temp$COUNTRY, "GR", "EL")
  }
  
  
  if (unique(temp$COUNTRY=="UK")){
    temp <- subset(temp, REGION != "N0")
  }
  
  temp$COUNTRY <- countrycode(temp$COUNTRY, origin = "eurostat", destination = "iso3c")
  
  temp <- merge(temp, pop_2017, by = "COUNTRY", all.x = T)
  
  if (unique(temp$COUNTRY=="FRA") | unique(temp$COUNTRY=="ESP")){
    temp$COEFF <- 1
  }
  
  temp$weight_adj <- temp$COEFF/sum(temp$COEFF)
  temp$COEFF <- NULL
  temp$weight_pop <- temp$weight_adj * temp$pop_2017
  
  
  temp <- temp %>% filter(AGE > 17 & AGE < 67)
  
  
  temp <- temp %>% filter(HHLINK==1 | HHLINK==2)
  
  
  
  temp$country_id <- temp$COUNTRY
  temp$hh_id <- paste0(temp$country_id, temp$QHHNUM, temp$YEAR)
  
  temp$sex <- temp$SEX
  temp$age <- temp$AGE

  temp <- temp %>% mutate(
    edu_lvl = case_when(
      HATLEV1D=="L" ~ 1,
      HATLEV1D=="M" ~ 2,
      HATLEV1D=="H" ~ 3
    )
  )
  
  temp$edu_secondary <- ifelse(temp$edu_lvl==2, 1, 0)
  temp$edu_tertiary <- ifelse(temp$edu_lvl==3, 1, 0)
  
  temp$lab_status <- temp$ILOSTAT
  
  temp$employed <- ifelse(temp$lab_status==1, 1, 0)
  temp <- temp %>% mutate(
    unemp = case_when(
      lab_status==2 ~ 1,
      lab_status==1 ~ 0
    )
  )
  temp$labor_force <- ifelse(temp$lab_status==1 | temp$lab_status==2, 1, 0)
  
  
  temp$foreign_bp <- ifelse(temp$COUNTRYB != "000-OWN COUNTRY", 1, 0)
  temp$foreign_cit <- ifelse(temp$NATIONAL != "000-OWN COUNTRY", 1, 0)
  
  
  temp$hwage <- NA
  temp$ln_hwage <- NA
  temp$earnings_all <- NA
  temp$earnings_bus <- NA
  temp$earnings_wage <- NA
  
  
  temp$selfemp <- NA
  temp$selfemp[temp$STAPRO == 3] <- 0
  temp$selfemp[temp$STAPRO %in% c(1, 2, 0)] <- 1
  
  
  temp$HWACTUAL[is.na(temp$HWACTUAL) | temp$HWACTUAL == 99] <- 0
  temp$HWACTUA2[is.na(temp$HWACTUA2) | temp$HWACTUA2 == 99] <- 0
  temp$hours_worked_act <- temp$HWACTUAL + temp$HWACTUA2
  
  temp$HWUSUAL[is.na(temp$HWUSUAL) | temp$HWUSUAL == 99] <- 0
  temp$hours_worked <- temp$HWUSUAL
  
  temp$informal_emp <- NA
  
  
  temp <- temp %>% mutate(
    isco_3d = case_when(
      lab_status == 1 ~ ISCO3D,
      lab_status > 1 & !is.na(ISCOPR3D) ~ ISCOPR3D
    )
  )
  
  temp$isco_3d <- ifelse(temp$isco_3d==999, NA, temp$isco_3d)
  temp <- merge(temp, unempl_rates_eu_lfs, by = "isco_3d", all.x = T)
  
  temp <- temp[with(temp, order(hh_id)),]
  row.names(temp) <- NULL

  
  temp <- temp[,c("hh_id",
                  "weight_adj", "weight_pop",
                  "sex", "age",
                  "edu_lvl", "edu_secondary", "edu_tertiary",
                  "lab_status", "employed", "unemp", "labor_force",
                  "REGION",
                  "foreign_bp", "foreign_cit",
                  "hwage", "ln_hwage", "earnings_all", "earnings_bus", "earnings_wage",
                  "selfemp", "hours_worked", "hours_worked_act", "informal_emp", 
                  "isco_3d", "unemp_occ_risk")]
  
  
  temp$na <- ifelse(is.na(temp$sex) | is.na(temp$age) | is.na(temp$edu_lvl) | is.na(temp$lab_status) | temp$REGION=="00", 1, 0)
  temp <- transform(temp, m_na = ave(temp$na, hh_id, FUN = mean))
  temp <- temp %>% filter(temp$m_na==0)
  temp$na <- NULL
  temp$m_na <- NULL
  temp$REGION <- NULL
  
  
  file <- substr(file, nchar(file)-11, nchar(file)-4)
  save(temp, file = paste0("../../bld/data/Europe/", file, "_filtered_ind.RData"))
  rm(temp, file)
  gc()
}


countries <- c("AT", "BE", "BG", "CY", "CZ", 
               "DE", "EE", "ES", "FR", "GR", 
               "HR", "HU", "IE", "IT", "LT", 
               "LU", "LV", "MT", "NL", "NO", 
               "PL", "PT", "RO", "SI", "SK", "UK")

for (country in countries){
  
  files_hh <- list.files(path="../../bld/data/Europe/", pattern=paste0(country, "[0-9][0-9][0-9][0-9]", "_y_filtered_hh"), full.names = TRUE)
  temp_hh <- files_hh %>%
    map_dfr(~ get(load(.)))
  rm(files_hh)
  
  files_ind <- list.files(path="../../bld/data/Europe/", pattern=paste0(country, "[0-9][0-9][0-9][0-9]", "_y_filtered_ind"), full.names = TRUE)
  temp_ind <- files_ind %>%
    map_dfr(~ get(load(.)))
  rm(files_ind)

  temp_hh <- temp_hh %>% filter(single==0)
  
  temp <- merge(temp_hh, temp_ind, by = c("hh_id"), all.x = T)
  rm(temp_hh, temp_ind)
  
  temp <- subset(temp, !((couple_type==2 & sex==2) | (couple_type==3 & sex==1)))
  
  country_new <- unique(temp$country_id)
  
  write_dta(temp, paste0("../../bld/data/data_countries/", "data_individual_", country_new, ".dta"))
  
  ids <- rbind(ids, temp)
}

rm(temp, country, country_new, unempl_rates_eu_lfs)





ids <- subset(ids, country_id == "BEL" | country_id == "DEU" | country_id == "FRA" | country_id == "NLD" | country_id == "GBR")
ids$QHHNUM <- substr(ids$hh_id, nchar(ids$hh_id)-11, nchar(ids$hh_id)-4)
ids_list <- unique(ids$hh_id)

files <- list()
for (c in c("BE", "DE", "FR", "NL", "UK")){
  for (y in seq(2015, 2019, 1)){
    file <- paste0(source_eu_lfs, c, y, "_y.csv")
    files <- append(files, file)
  }
}
files <- as.character(files)

data <- do.call(rbind, lapply(files, read.csv))
data <- data[,c("COUNTRY", "YEAR", "QHHNUM", "HHLINK", "AGE", "DEGURBA", "COEFF", "REGION")]

data <- subset(data, REGION != "N0")

data$COUNTRY <- countrycode(data$COUNTRY, origin = "eurostat", destination = "iso3c")

data$COEFF_2 <- ifelse(data$COUNTRY == "FRA", 1, data$COEFF)
data <- data %>% group_by(COUNTRY, YEAR) %>%
  mutate(sum_COEFF = sum(COEFF_2))
data$weight_adj <- data$COEFF_2/data$sum_COEFF

data$hh_id <- paste0(data$COUNTRY, data$QHHNUM, data$YEAR)
data <- data[data$hh_id %in% ids_list, ]

ids <- ids[,c("hh_id", "couple_type")]
ids <- unique(ids)

data <- merge(data, ids, by = "hh_id", all.x = T)
rm(ids, ids_list)



data <- subset(data, HHLINK > 2)


data <- subset(data, AGE < 17)

data$under_15_status <- case_when(
  data$HHLINK == 3 ~ 1, # child
  data$HHLINK == 4 | data$HHLINK == 5 ~ 2, # other relative
  data$HHLINK == 6 ~ 3 # other non-relative
) 
data <- subset(data, !is.na(under_15_status))

data$child <- ifelse(data$under_15_status == 1, 1, 0)
data$other_relative <- ifelse(data$under_15_status == 2, 1, 0)
data$other_non_relative <- ifelse(data$under_15_status == 3, 1, 0)

data <- subset(data, DEGURBA==1 | DEGURBA==2)

under_15_couple_type <- data %>%
  group_by(COUNTRY, couple_type) %>%
  summarise(mean_child = weighted.mean(child, weight_adj),
            mean_other_relative = weighted.mean(other_relative, weight_adj),
            mean_other_non_relative = weighted.mean(other_non_relative, weight_adj))

colnames(under_15_couple_type)[3:5] <- c("child", "other_relative", "other_non_relative")

# Table A.11 input
write_dta(under_15_couple_type, paste0("../../bld/data/descriptives/under_15/", "under_15_couple_type_eu_lfs.dta"))








data <- do.call(rbind, lapply(files, read.csv))
data <- data[,c("COUNTRY", "YEAR", "QHHNUM", "HHLINK", "HHSEQNUM", "HHSPOU", "AGE", "DEGURBA", "COEFF", "REGION")]

data <- subset(data, REGION != "N0")

data$COUNTRY <- countrycode(data$COUNTRY, origin = "eurostat", destination = "iso3c")

data$COEFF_2 <- ifelse(data$COUNTRY == "FRA", 1, data$COEFF)
data <- data %>% group_by(COUNTRY, YEAR) %>%
  mutate(sum_COEFF = sum(COEFF_2))
data$weight_adj <- data$COEFF_2/data$sum_COEFF

data <- subset(data, DEGURBA==1 | DEGURBA==2)
data <- subset(data, AGE > 17 & AGE < 67)
data <- subset(data, HHLINK != 9)

data$hh_id <- paste0(data$COUNTRY, data$QHHNUM, data$YEAR)



data <- subset(data, HHSPOU != 0)


data$adult <- 1

data <- data %>% 
  group_by(hh_id) %>%
  mutate(sum_adult = sum(adult))



data <- subset(data, sum_adult != 1)


data$min <- pmin(data$HHSEQNUM, data$HHSPOU)
data$max <- pmax(data$HHSEQNUM, data$HHSPOU)

data$pair <- paste(data$min, data$max, sep = "")

data$couple_id <- paste0(data$hh_id, data$pair)


check <- data %>% 
  group_by(couple_id) %>%
  count()

data <- merge(data, check, by = "couple_id", all.x = T)


data <- subset(data, n == 2)


data <- data %>% 
  group_by(couple_id) %>%
  mutate(min_HHLINK = min(HHLINK))


data$hh_head <- ifelse(data$min_HHLINK == 1, 1, 0)

data <- data[,c("COUNTRY", "couple_id", "hh_head", "weight_adj")]


data <- data %>% 
  group_by(COUNTRY) %>%
  summarise(relation = weighted.mean(hh_head, weight_adj))

data <- unique(data)
# Figure D.3 input
write_dta(data, paste0("../../bld/data/descriptives/hh_head_all_couples/", "hh_head_all_couples_eu_lfs.dta"))







rpa.2015 <- read.csv(paste0(source_rpa_ghs, "GHS 2015 Person v1.2 CSV.csv"))
rpa.2015 <- rpa.2015[,c("uqnr", "personnr", "q11RELSH", "gender", "Age", "Metro")]
colnames(rpa.2015) <- c("hh_id", "id", "hhh_rel", "gender", "age", "metro")

rpa.2015 <- rpa.2015 %>% filter(hhh_rel==1 | hhh_rel==2)
rpa.2015 <- rpa.2015 %>% filter(metro==1)
rpa.2015$adult <- ifelse(rpa.2015$age>=18 & rpa.2015$age<65, 1, 0)
rpa.2015 <- rpa.2015 %>% filter(age>=18 & age<65)
rpa.2015 <- rpa.2015 %>%
  group_by(hh_id) %>%
  mutate(sum_adult = sum(adult))
rpa.2015 <- rpa.2015 %>% filter(sum_adult==2)
rpa.2015 <- rpa.2015 %>%
  group_by(hh_id) %>%
  mutate(mean_sex = mean(gender))
rpa.2015$couple_type2 <- case_when(
  rpa.2015$mean_sex==1.5 ~ 1, # different-sex
  rpa.2015$mean_sex==1 | rpa.2015$mean_sex==2 ~ 2 # ssc
)
rpa.2015 <- rpa.2015[,c("couple_type2")]
rpa.2015$year <- 2015
rpa.2015 <- rpa.2015 %>%
  group_by(year, couple_type2) %>%
  mutate(nobs = n())
rpa.2015 <- rpa.2015[,c("couple_type2", "year", "nobs")]
rpa.2015 <- unique(rpa.2015)
colnames(rpa.2015)[1] <- "couple_type"
rpa.2015$country <- "ZAF"


rpa.2016 <- read.csv(paste0(source_rpa_ghs, "GHS 2016 Person v1.1 CSV.csv"))
rpa.2016 <- rpa.2016[,c("UqNr", "PersonNR", "Q11RELSH", "Gender", "Age", "Metro")]
colnames(rpa.2016) <- c("hh_id", "id", "hhh_rel", "gender", "age", "metro")

rpa.2016 <- rpa.2016 %>% filter(hhh_rel==1 | hhh_rel==2)
rpa.2016 <- rpa.2016 %>% filter(metro==1)
rpa.2016$adult <- ifelse(rpa.2016$age>=18 & rpa.2016$age<65, 1, 0)
rpa.2016 <- rpa.2016 %>% filter(age>=18 & age<65)
rpa.2016 <- rpa.2016 %>%
  group_by(hh_id) %>%
  mutate(sum_adult = sum(adult))
rpa.2016 <- rpa.2016 %>% filter(sum_adult==2)
rpa.2016 <- rpa.2016 %>%
  group_by(hh_id) %>%
  mutate(mean_sex = mean(gender))
rpa.2016$couple_type2 <- case_when(
  rpa.2016$mean_sex==1.5 ~ 1, # different-sex
  rpa.2016$mean_sex==1 | rpa.2016$mean_sex==2 ~ 2 # ssc
)
rpa.2016 <- rpa.2016[,c("couple_type2")]
rpa.2016$year <- 2016
rpa.2016 <- rpa.2016 %>%
  group_by(year, couple_type2) %>%
  mutate(nobs = n())
rpa.2016 <- rpa.2016[,c("couple_type2", "year", "nobs")]
rpa.2016 <- unique(rpa.2016)
colnames(rpa.2016)[1] <- "couple_type"
rpa.2016$country <- "ZAF"


rpa.2017 <- read.csv(paste0(source_rpa_ghs, "GHS 2017 Person v1.0 CSV.csv"))
rpa.2017 <- rpa.2017[,c("UqNr", "PersonNR", "Q11RELSH", "Gender", "Age", "Metro")]
colnames(rpa.2017) <- c("hh_id", "id", "hhh_rel", "gender", "age", "metro")

rpa.2017 <- rpa.2017 %>% filter(hhh_rel==1 | hhh_rel==2)
rpa.2017 <- rpa.2017 %>% filter(metro==1)
rpa.2017$adult <- ifelse(rpa.2017$age>=18 & rpa.2017$age<65, 1, 0)
rpa.2017 <- rpa.2017 %>% filter(age>=18 & age<65)
rpa.2017 <- rpa.2017 %>%
  group_by(hh_id) %>%
  mutate(sum_adult = sum(adult))
rpa.2017 <- rpa.2017 %>% filter(sum_adult==2)
rpa.2017 <- rpa.2017 %>%
  group_by(hh_id) %>%
  mutate(mean_sex = mean(gender))
rpa.2017$couple_type2 <- case_when(
  rpa.2017$mean_sex==1.5 ~ 1, # different-sex
  rpa.2017$mean_sex==1 | rpa.2017$mean_sex==2 ~ 2 # ssc
)
rpa.2017 <- rpa.2017[,c("couple_type2")]
rpa.2017$year <- 2017
rpa.2017 <- rpa.2017 %>%
  group_by(year, couple_type2) %>%
  mutate(nobs = n())
rpa.2017 <- rpa.2017[,c("couple_type2", "year", "nobs")]
rpa.2017 <- unique(rpa.2017)
colnames(rpa.2017)[1] <- "couple_type"
rpa.2017$country <- "ZAF"


rpa.2018 <- read.csv(paste0(source_rpa_ghs, "ghs-2018-person-1.0-csv.csv"))
rpa.2018 <- rpa.2018[,c("UqNr", "PersonNR", "Q11RELSH", "Gender", "Age", "Metro")]
colnames(rpa.2018) <- c("hh_id", "id", "hhh_rel", "gender", "age", "metro")

rpa.2018 <- rpa.2018 %>% filter(hhh_rel==1 | hhh_rel==2)
rpa.2018 <- rpa.2018 %>% filter(metro==1)
rpa.2018$adult <- ifelse(rpa.2018$age>=18 & rpa.2018$age<65, 1, 0)
rpa.2018 <- rpa.2018 %>% filter(age>=18 & age<65)
rpa.2018 <- rpa.2018 %>%
  group_by(hh_id) %>%
  mutate(sum_adult = sum(adult))
rpa.2018 <- rpa.2018 %>% filter(sum_adult==2)
rpa.2018 <- rpa.2018 %>%
  group_by(hh_id) %>%
  mutate(mean_sex = mean(gender))
rpa.2018$couple_type2 <- case_when(
  rpa.2018$mean_sex==1.5 ~ 1, # different-sex
  rpa.2018$mean_sex==1 | rpa.2018$mean_sex==2 ~ 2 # ssc
)
rpa.2018 <- rpa.2018[,c("couple_type2")]
rpa.2018$year <- 2018
rpa.2018 <- rpa.2018 %>%
  group_by(year, couple_type2) %>%
  mutate(nobs = n())
rpa.2018 <- rpa.2018[,c("couple_type2", "year", "nobs")]
rpa.2018 <- unique(rpa.2018)
colnames(rpa.2018)[1] <- "couple_type"
rpa.2018$country <- "ZAF"


rpa.2019 <- read.csv(paste0(source_rpa_ghs, "zaf-statssa-ghs-2019-person-v1-csv.csv"))
rpa.2019 <- rpa.2019[,c("uqnr", "personnr", "HHC_RELATIONSHIP", "Sex", "age", "metro")]
colnames(rpa.2019) <- c("hh_id", "id", "hhh_rel", "gender", "age", "metro")
rpa.2019$gender <- ifelse(rpa.2019$gender=="Male", 1, 2)

rpa.2019 <- rpa.2019 %>% filter(hhh_rel=="Head/acting head" | hhh_rel=="Husband/wife/partner of household head")
rpa.2019 <- rpa.2019 %>% filter(metro=="Metro")
rpa.2019$adult <- ifelse(rpa.2019$age>=18 & rpa.2019$age<65, 1, 0)
rpa.2019 <- rpa.2019 %>% filter(age>=18 & age<65)
rpa.2019 <- rpa.2019 %>%
  group_by(hh_id) %>%
  mutate(sum_adult = sum(adult))
rpa.2019 <- rpa.2019 %>% filter(sum_adult==2)
rpa.2019 <- rpa.2019 %>%
  group_by(hh_id) %>%
  mutate(mean_sex = mean(gender))
rpa.2019$couple_type2 <- case_when(
  rpa.2019$mean_sex==1.5 ~ 1, # different-sex
  rpa.2019$mean_sex==1 | rpa.2019$mean_sex==2 ~ 2 # ssc
)
rpa.2019 <- rpa.2019[,c("couple_type2")]
rpa.2019$year <- 2019
rpa.2019 <- rpa.2019 %>%
  group_by(year, couple_type2) %>%
  mutate(nobs = n())
rpa.2019 <- rpa.2019[,c("couple_type2", "year", "nobs")]
rpa.2019 <- unique(rpa.2019)
colnames(rpa.2019)[1] <- "couple_type"
rpa.2019$country <- "ZAF"

rpa <- rbind(rpa.2015, rpa.2016, rpa.2017, rpa.2018, rpa.2019)
# Table D.4 input
write_dta(rpa, paste0("../../bld/data/counts/ZAF_ssh_obs_yrs.dta"))
rm(rpa, rpa.2015, rpa.2016, rpa.2017, rpa.2018, rpa.2019)


