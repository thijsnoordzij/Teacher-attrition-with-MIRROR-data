# Open MIRROR-file from SPSS .sav file extension
# It takes about 1 minute to load the data

library(haven)  # faster than using the foreign library, and without error message. 
data <- read_spss("C:/Users/Thijs/Documents/MIRROR/data/mirror_formatie_ tm2014.sav")
# system.time: 
# user  system elapsed 
# 40.72    0.33   41.08 

# library(foreign)
# data <- read.spss("C:/Users/Thijs/Documents/MIRROR/data/mirror_formatie_ tm2014.sav", to.data.frame = TRUE)
# system.time: 
# user  system elapsed 
# 76.58    1.84   78.48 