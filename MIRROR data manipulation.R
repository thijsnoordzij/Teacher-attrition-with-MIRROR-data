# Open MIRROR-file from SPSS .sav file extension

# haven package is faster than foreign package, and without error message. 
# Variable labels are stored in the "label" attribute of each variable.
if (require("haven")){
  print("haven is loaded correctly")
} else {
  print("trying to install haven")
  install.packages("haven")
  if(require("haven")){
    print("haven installed and loaded")
  } else {
    stop("could not install haven")
  }
}

# system.time: 
# user  system elapsed 
# 40.72    0.33   41.08 
data <- read_spss("C:/Users/Thijs/Documents/MIRROR/data/mirror_formatie_ tm2014.sav")
testdata <- data[1:50001,]

# Basic descriptives
library(Hmisc)
describe(data$FCAT[data$JAAR==2000], exclude.missing = F) 

# Define NA in FUNGRP(_PVE1), BRIN, GEBDAT, GESLACHT
missing_FUNGRP <- c(-1) # NA defined as in SPSS file for MIRROR provided by DUO. FUNGRP also has 2431 system.missings in SPSS
data$FUNGRP <- lapply(data$FUNGRP, function(x) replace(x, x %in% missing_FUNGRP, NA))
data$FUNGRP <- as.numeric(data$FUNGRP)
# user  system elapsed 
# 29.65    0.13   29.92 

missing_FUNGRP_PVE1 <- c(-1) # NA defined as in SPSS file for MIRROR provided by DUO. FUNGRP also has 2869 system.missings in SPSS
data$FUNGRP_PVE1 <- lapply(data$FUNGRP_PVE1, function(x) replace(x, x %in% missing_FUNGRP_PVE1, NA))
data$FUNGRP_PVE1 <- as.numeric(data$FUNGRP_PVE1)

compare_FUNGRP_FUNGRP_PVE1 <- table(data$FUNGRP, data$FUNGRP_PVE1, exclude = NULL)
write.csv2(compare_FUNGRP_FUNGRP_PVE1, file = "C:/Users/Thijs/Documents/MIRROR/Output/compare_FUNGRP_FUNGRP_PVE1.csv")
# Value labels are still missing. 

missing_BRIN <- c("O") # NA defined as in SPSS file for MIRROR provided by DUO.
# missing_BRIN2 <- c("O", "VMB", "0000", "P&O", "PR", "SB O", "STAF", "TEAM") # Several unlikely BRIN, possible NA. With deeper search, likely to find more incorrect BRIN that are actually NA. 
data$BRIN <- lapply(data$BRIN, function(x) replace(x, x %in% missing_BRIN, NA))
# user  system elapsed 
# 30.81    0.02   30.83 

missing_GEBDAT <- c(-1) # NA defined as in SPSS file for MIRROR provided by DUO.
data$GEBDAT <- lapply(data$GEBDAT, function(x) replace(x, x %in% missing_GEBDAT, NA))
# user  system elapsed 
# 54.51    0.11   54.81 

class(data$GEBDAT)

missing_GESLACHT <- c("", "O") # NA defined as in SPSS file for MIRROR provided by DUO, "" (empty string) added. 
data$GESLACHT <- lapply(data$GESLACHT, function(x) replace(x, x %in% missing_GESLACHT, NA))
# user  system elapsed 
# 30.50    0.06   30.60 

sum(is.na(data$BRIN))         # 1393
sum(is.na(data$GEBDAT))       # 4156
sum(is.na(data$GESLACHT))     # 4059 (if " " is added as missing value, else 0)
sum(is.na(data$FUNGRP))       # 10559, that includes 2431 system.missing in SPSS
sum(is.na(data$FUNGRP_PVE1))  # 9067, that includes 2869 system.missing in SPSS


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
data$validbrin <- as.logical(data$validbrin)

length(data$validbrin[data$validbrin==FALSE]) # 43636 invalid BRIN. 

-# To do: check if/how incorrect BRIN are related to other variables
data_invalidbrin <- subset(data, validbrin==FALSE)
table(data$validbrin, exclude = NULL)
# FALSE    TRUE    <NA> 
#   43636 6407015       0 

BRIN_FUNGRP_table <- table(data$validbrin, data$FUNGRP_PVE1, exclude = NULL)
BRIN_FUNGRP_prop.table <- prop.table(table(data$validbrin, data$FUNGRP_PVE1, exclude = NULL), 1)
write.csv2(BRIN_FUNGRP_table, file = "C:/Users/Thijs/Documents/MIRROR/Output/BRIN_FUNGRP_table.csv")
write.csv2(BRIN_FUNGRP_prop.table, file = "C:/Users/Thijs/Documents/MIRROR/Output/BRIN_FUNGRP_prop.table.csv")
barplot(BRIN_FUNGRP_prop.table, main = "Proportion of valid BRIN per job", xlab = "Job", legend = c("invalid BRIN", "valid BRIN"), col=c("red","darkgreen"), beside = TRUE)

head(data$FUNGRP_PVE1)

mytable <- table(data_invalidbrin$JAAR, data_invalidbrin$FUNGRP_PVE1, exclude=NULL)
mytable

mytable <- table(data$JAAR, data$FUNGRP_PVE1, exclude=NULL)
mytable
prop.table(mytable, 1)

class(data_invalidbrin$FUNGRP)

sum(is.na(data_invalidbrin$FUNGRP))/length(data_invalidbrin$FUNGRP)

complete.cases(data_invalidbrin$FUNGRP) # NA's a problem?

getwd()
tmp <- tempfile(fileext = ".sav")
write.csv(data_invalidbrin, "C:/Users/Thijs/Documents/MIRROR/data/invalid_brin.csv")

head(data_invalidbrin)

# install.packages("ggplot2")
library(ggplot2)
invalidbrin_FUNGRP <- ggplot(data_invalidbrin, aes(FUNGRP))
invalidbrin_FUNGRP + geom_histogram(stat = "count", binwidth = 1, bins = NULL)


# data$FUNGRP[data$validbrin==FALSE]
# count(data[,'JAAR'][!y])
# count(data[!y,], vars = c('BESTUUR1'))
# sum(data$FUNGRP[data$validbrin==FALSE][data$FUNGRP==1])
# data$FUNGRP[data$FUNGRP==1][data$validbrin==FALSE]


# Duplicate records
library(plyr)

data1 <- data[, c("id_2015", "JAAR", "BRIN", "BESTUUR1", "GEBDAT", "GESLACHT", "FUNGRP")]
data1$koppelprobleem <- apply(data1, 1, anyNA)
# user  system elapsed 
# 20.10    0.26   20.38 
sum(data1$koppelprobleem) # 18450 records have one or more NA's in variables used for linking to other data. 

# check for persons (id_2015) with one or more recors with one or more NA's in variables used for linking to other data. 
id_data <- ddply(data1, "id_2015", summarise, koppelprobleem_record = max(koppelprobleem))
sum(id_data$koppelprobleem_record) # 16868 out of 629793 persons (2.68%)

# idem for most recent year (2014)
id_data_2014 <- ddply(data1[data1$JAAR==2014,], "id_2015", summarise, koppelprobleem_record = max(koppelprobleem))
sum(id_data_2014$koppelprobleem_record) # 505 out of 332418 persons (0,15%)

# idem for most recent 6 years (2008 - 2014)
id_data_20092014 <- ddply(subset(data1, JAAR >= 2008), "id_2015", summarise, koppelprobleem_record = max(koppelprobleem))
sum(id_data_20092014$koppelprobleem_record) # 16759 out of 478643 persons (3,50%)


head(data1[which(data1$JAAR==(2009:2014)), ])
head(data1[data1$JAAR==2014, ])
head(subset(data1, JAAR >= 2008))


min(c(T,T,F))

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
# The not-sophisticated way: http://www.statmethods.net/input/valuelabels.html
data$FUNGRP_PVE1 <- factor(data$FUNGRP_PVE1,
  levels = c(-1,1,2,3,4,5),
  labels = c("onbekend", "directie, management", "onderwijzend personeel, leraren", "onderwijsondersteunend personeel", "beheer- en administratief personeel", "leraren in opleiding"))
# Dit geeft problemen bij het benoemen van NA's in eerdere syntax. 

# Or, alternatively: 
# data$FUNGRP_PVE1 <- factor(data$FUNGRP_PVE1,
#   levels = c(1,2,3,4,5),
#   labels = c("directie/management", "OP", "OOP", "OBP", "LIO"))


# 2. Convert some variables to nominal variables (factor?)

# 3. Create date variable out of GEBDAT

# convert string date variable to date
data$GEBDATdate <- sapply(data$GEBDAT, function(x) as.Date(toString(x), format = "%Y%m%d"))
class(data$GEBDATdate) <- "Date"

# user  system elapsed 
# 213.00    0.07  213.45 

# 4. Fill missing GEBDAT is known within same id_2015? Maybe not: id_2015 might not be very reliable if date of birth is missing.
