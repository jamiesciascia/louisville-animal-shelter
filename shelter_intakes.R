# INSTALL, LOAD, READ

library(tidyverse)
library(lubridate)
#library(zipcodeR)

intake_outcome_ky <- read_csv("~/Downloads/Louisville_Intake_and_Outcome.csv")
#data("zip_code_db")

# CLEAN

# create clean data frame and add desired columns
intake_clean <- intake_outcome_ky %>%
  filter(animaltype == 'DOG',
         ! intype %in% c('DISPOSAL', 
                         'FOR TRANSP', 
                         'FOSTER', 
                         'FOUND', 
                         'LOST', 
                         'EVACUEE')) %>%
  mutate(year = indate, 
         zipcode = sourcezipcode, 
         is_mix = grepl('/', breed)) 
intake_strays <- intake_clean %>%
  filter(intype == 'STRAY')

#format dates
intake_clean$indate <- ymd_hms(intake_clean$indate)
intake_clean$indate <- as.Date(intake_clean$indate)
intake_clean$year <- ymd_hms(intake_clean$year) 
intake_clean$year <- as.Date(intake_clean$year)
intake_clean$year <- as.numeric(format(intake_clean$year, format = "%Y"))

#PREPARATION

#color palette for visualizations
mycolors <- c("#8DD3C7", "#BFE6BE", "#F1F9B5", "#EAE8BF", "#CDCAD0", "#CAAEC5", "#E59497", "#F18379",
              "#BB99A4", "#84AFCF", "#B2B2A5", "#E8B374", "#E8BF63", "#C7D267", "#BEDB7C", "#DED3B3",
              "#FACDE4", "#EBD2DF", "#DBD8D9", "#CEB8CE", "#C191C2", "#BF99BE", "#C6C8C2", "#D2EBBA",
              "#E8EC94", "#FFED6F")

#SELECTING AND VISUALIZING DATA

#data frame to count intake types for dogs that need a home
intake_type <- intake_clean %>%
  count(intype, sort = TRUE) %>% 
  rename(dogintakes = n) %>%
  mutate(percent = round((dogintakes / sum(dogintakes)) * 100))

##visualization
pie(intake_type$dogintakes, 
    labels=paste(intake_type$intype, " ", intake_type$percent, "%"), 
    main="Dog Intake Reason", 
    col= mycolors )

#data frame to count surrender reasons for strays
strays <- intake_clean %>%
  filter(intype == 'STRAY')
strays$surreason[strays$surreason != 'STRAY'] <- 'OTHER'
strays <- strays %>%
  count(surreason, sort = TRUE) %>%
  rename(num_dogs = n) %>%
  mutate(percent = round((num_dogs / sum(num_dogs)) * 100))

##visualization
pie(strays$num_dogs, 
    labels=paste(strays$surreason, "", strays$percent, "%"), 
    main="Surrender Reason for Strays", 
    col= mycolors)

#data frame for sex of dog
sexstatus <- intake_clean %>%
  mutate(sextype = "") %>%
  filter(intype == 'STRAY', surreason == 'STRAY', sex != 'U') 
sexstatus$sextype[sexstatus$sex %in% c('S', 'N')] <- 'FIXED'
sexstatus$sextype[sexstatus$sex %in% c('M', 'F')] <- 'INTACT'
sexstatus <- sexstatus %>%
  count(sextype) %>%
  rename(num_dogs = n) %>%
  mutate(percent = round((num_dogs / sum(num_dogs)) * 100))

##visualization
pie(sexstatus$num_dogs,
    labels = paste(sexstatus$sextype, "", sexstatus$percent, "%"),
    main = "Fixed vs. Intact Strays",
    col = mycolors) 

#TIBBLES

intake_strays %>%
  count(zipcode, sort = TRUE)

intake_strays %>%
  count(zipcode, breed, sort = TRUE)

#CREATING MAP OF DOGS IN LOUISVILLE

#merging map data
#intake_latlng_merged <- inner_join(intake_clean, zip_code_db, by='zipcode') %>% 
#filter(state == 'KY' & county == "Jefferson County")

#creating map df
#ky_map <- map_data("county", "kentucky") %>% 
#select(lng = long, lat, group, id = subregion) %>% 
#filter(id == "jefferson")

#ggplot() +
#geom_polygon(data = ky_map, aes(lng, lat, group = group), fill= "white", color = "grey50") +
#geom_jitter(data = intake_latlng_merged, aes(x=lng, y=lat), shape = 1)