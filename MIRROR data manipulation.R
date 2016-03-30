# Open MIRROR-file from SPSS .sav file extension

# install.packages("haven")
library(haven)  
# haven package is faster than foreign package, and without error message. 
# Variable labels are stored in the "label" attribute of each variable.

# It takes almost 1 minute to load the data
data <- read_spss("C:/Users/Thijs/Documents/MIRROR/data/mirror_formatie_ tm2014.sav")
# system.time: 
# user  system elapsed 
# 40.72    0.33   41.08 
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


# Validate BRIN
# - Check if remainig values comply to rules of BRIN (string-string-integer-integer)
#
# Strategy:
#   - write function that identifies (in)correct values for BRIN
#   - use apply function on data['BRIN']
# 
# source valid.brin function to check if entries in BRIN variable are valid. 
source('E:/Google Drive/Promotie/Analyse/Teacher-attrition-with-MIRROR-data/validBRIN.R')
# 
# apply valid.brin on complete data['BRIN']
y <- sapply(data[,'BRIN'], valid.brin) # werkt, maar duurt lang: >35 minuten
# check if/how incorrect BRIN are related to other variables
# 
library(plyr)
count(data[,'JAAR'][!y])
count(data[!y,], vars = c('BESTUUR1'))


# aggregate data from record to person
library(plyr)

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

### to do: als ik de dataset 'summarise' op FUNGRP, BRIN, GESLACHT en GEBDAT (opgesplitst per JAAR), hoe veel dubbele id_2015 heb ik dan? 
testdata7 <- ddply(testdata, c("BRIN", "GEBDAT", "GESLACHT", "FUNGRP"), summarise, n_rec = max(id_2015))
testdata8 <- ddply(testdata, c("BRIN", "GEBDAT", "GESLACHT", "FUNGRP"), summarise, n_rec = min(id_2015))
testdata9 <- testdata8$n_rec - testdata7$n_rec

head(testdata9)
count(testdata9)

(max(id_2015)-min(id_2015)+1)

# ... function(x) replace(x, x %in% missing_FUNGRP, ... 



sum(is.na(testdata2$id_2015))

aggdata <- aggregate(data, by=list('BRIN'), FUN=is.na, na.rm=FALSE) # na.rm=FALSE is default, maar voor de duidelijkheid toegevoegd aan de formule. 

attach(mtcars)
aggdata <-aggregate(mtcars$mpg, by=list(cyl,vs), FUN=mean, na.rm=F)
print(aggdata)

is.na.data.frame(mtcars)

mtcars$mpg[1]<-NA



# To do: 
# 1. How to get the value labels out of the SPSS-file?

# 2. Convert some variables to nominal variables (factor?)

# 3. Create date variable out of GEBDAT

# 4. Fill missing GEBDAT is known within same id_2015? Maybe not: id_2015 might not be very reliable if date of birth is missing.
