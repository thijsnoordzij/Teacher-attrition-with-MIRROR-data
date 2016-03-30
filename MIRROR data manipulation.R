# Open MIRROR-file from SPSS .sav file extension

# install.packages("haven")
# haven package is faster than foreign package, and without error message. 
# Variable labels are stored in the "label" attribute of each variable.
library(haven)  

# It takes almost 1 minute to load the data
# system.time: 
# user  system elapsed 
# 40.72    0.33   41.08 
data <- read_spss("C:/Users/Thijs/Documents/MIRROR/data/mirror_formatie_ tm2014.sav")
testdata <- data[1:50001,]

# Define NA in FUNGRP, BRIN, GEBDAT, GESLACHT
missing_FUNGRP <- c(-1) # NA defined as in SPSS file for MIRROR provided by DUO. FUNGRP also has 2431 system.missings in SPSS
data$FUNGRP <- lapply(data$FUNGRP, function(x) replace(x, x %in% missing_FUNGRP, NA))
# user  system elapsed 
# 29.65    0.13   29.92 

missing_BRIN <- c("O") # NA defined as in SPSS file for MIRROR provided by DUO.
# missing_BRIN2 <- c("O", "VMB", "0000", "P&O", "PR", "SB O", "STAF", "TEAM") # Several unlikely BRIN, possible NA. With deeper search, likely to find more incorrect BRIN that are actually NA. 
data$BRIN <- lapply(data$BRIN, function(x) replace(x, x %in% missing_BRIN, NA))
# user  system elapsed 
# 30.81    0.02   30.83 

missing_GEBDAT <- c(-1) # NA defined as in SPSS file for MIRROR provided by DUO.
data$GEBDAT <- lapply(data$GEBDAT, function(x) replace(x, x %in% missing_GEBDAT, NA))
# user  system elapsed 
# 54.51    0.11   54.81 

missing_GESLACHT <- c("", "O") # NA defined as in SPSS file for MIRROR provided by DUO, "" (empty string) added. 
data$GESLACHT <- lapply(data$GESLACHT, function(x) replace(x, x %in% missing_GESLACHT, NA))
# user  system elapsed 
# 30.50    0.06   30.60 

sum(is.na(data$BRIN))     # 1393
sum(is.na(data$GEBDAT))   # 4156
sum(is.na(data$GESLACHT)) # 4059 (if " " is added as missing value, else 0)
sum(is.na(data$FUNGRP))   # 10559, that includes 2431 system.missing in SPSS

head(data$BRIN)

# Validate BRIN
# 
# BRIN is a unique identifier for a school. BRIN has a standard format: 4 
# characters, number, number, character, character (e.g. "11AO"). Some BRIN in 
# the MIRROR-file do not represent the school where the staff (teacher or 
# otherwise) works. These 'BRIN' represent staff working under direct 
# responsibility of the board. These BRIN have a free format, which deviates 
# from the previously mentioned standard format. Possibly, these BRIN are also 
# not identical for the same school in different years.
# 
# valid.brin is a function that identifies (in)correct values for BRIN. This
# function is used to make a new variable in the data of the MIRROR-file
# (data$validbrin). valid.brin is sourced from a separate file.
source('E:/Google Drive/Promotie/Analyse/Teacher-attrition-with-MIRROR-data/validBRIN.R')
data$validbrin <- lapply(data$BRIN, valid.brin) # the funtion works, but it takes ca. 35 minutes to complete the operation. 

# To do: check if/how incorrect BRIN are related to other variables
# library(plyr)
# count(data[,'JAAR'][!y])
# count(data[!y,], vars = c('BESTUUR1'))


# Duplicate records
library(plyr)
testdataA <- testdata$id_2015
testdataA <- as.data.frame(testdataA)
cbind(testdataA, testdata$id_2015, testdata$GEBDAT, testdata$GESLACHT, testdata$JAAR, data$FUNGRP, testdata$BRIN)

duplicated(testdata)


# Create variable for entry and exit into the labor force. 
testdata2 <- ddply(testdata, "id_2015", summarise, first_year = min(JAAR))  # summarise function aggregates data frame by "id_2015"
testdata3 <- ddply(testdata, "id_2015", summarise, last_year = max(JAAR))
# user  system elapsed 
# 2.52    0.03    2.55 

testdata4 <- merge(testdata2, testdata3)
testdata5 <- merge(testdata, testdata4)

head(testdata2)
head(testdata3)
head(testdata4)
head(testdata5)

testdata6 <- ddply(testdata, c("id_2015", "FUNGRP"), summarise, last_year = max(JAAR))  # FUNGRP is used for MIRROR, a model for labour market estimates. Most likely the best variable to use to determine if someone is a teacher. 
head(testdata6)


# To do: 
# 1. How to get the value labels out of the SPSS-file?

# 2. Convert some variables to nominal variables (factor?)

# 3. Create date variable out of GEBDAT

# 4. Fill missing GEBDAT is known within same id_2015? Maybe not: id_2015 might not be very reliable if date of birth is missing.
