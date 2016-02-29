# Open MIRROR-file from SPSS .sav file extension


library(haven)  
# haven package is faster than foreign package, and without error message. 
# Variable labels are stored in the "label" attribute of each variable.

# It takes about 1 minute to load the data
data <- read_spss("C:/Users/Thijs/Documents/MIRROR/data/mirror_formatie_ tm2014.sav")
# system.time: 
# user  system elapsed 
# 40.72    0.33   41.08 

# To do: 
# 1. How to get the value labels out of the SPSS-file?

# 2. Convert some variables to nominal variables (factor?)

# 3. Create date variable out of GEBDAT

# 4. Fill missing GEBDAT is known within same id_2015
# SPSS syntax used to fill missing GEBDAT and GESLACHT: 
#   * Vullen missende geboortedatum en geslacht als er wel een geboortedatum/geslacht bekend is binnen een id_2015. 
# SORT CASES BY id_2015(A) Geboortedatum(D).
# IF (id_2015 = LAG(id_2015)) AND (SYSMIS(Geboortedatum) ) Geboortedatum = LAG(Geboortedatum). 
# SORT CASES BY id_2015(A) GESLACHT(D).
# IF (id_2015 = LAG(id_2015)) AND (SYSMIS(GESLACHT) ) GESLACHT = LAG(GESLACHT). 
# EXECUTE.

# perhaps the zoo library has good options to handle missing data?

library(plyr) # helpfull tutorial of plyr: http://www.r-bloggers.com/a-fast-intro-to-plyr-for-r/

# Test with small set of total data (50k of the 6,5M, <1%)
subdata <- data[1:50001,]


temptab <- ddply(subdata, c("id_2015", "GEBDAT"), function(df)max(df$GEBDAT)) # for every id_2015, if one of the GEBDAT is NA, this returns NA for the whole id_2015
temptab2 <- ddply(subdata, c("id_2015", "GEBDAT"), function(df)max(df$GEBDAT,na.rm = TRUE)) # for every id_2015, if one of the GEBDAT is NA, this returns the maximum. If all GEBDAT is NA, this returns -Inf for the whole id_2015

head(temptab)

x <- temptab[,"GEBDAT"] - temptab[,"V1"]

temptab <- cbind(temptab, x)

sum(is.na(temptab[,"x"]))

tmp <- count(data1[,"id_2015"]) # 4548 observations, while temptab has 4550 oberservations. That means temptab shows id_2015's with more than one GEBDAT more than once. 

y <- c(1,2,3,NA)
z <- c(NA, NA)
max(y) # returns NA
max(y,na.rm = TRUE) # returns 3
max(z,na.rm = TRUE) # returns -Inf
