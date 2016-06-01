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

# convert numeric date variable to string
data$GEBDATstring <- sapply(data$GEBDAT, toString)

# convert string date variable to date
data$GEBDATdate <- sapply(data$GEBDATstring, function(x) as.Date(x, format = "%Y%m%d"))

class(data$GEBDATdate) <- "Date"

# Alternative (not working yet?)
# Create a custom function to specify the format of the numeric date variable
# GEBDAT Found information on which symbols are used for the format() function
# on http://www.statmethods.net/input/dates.html
mydatefunc <- function(num_date){
  date <- as.Date(as.character(num_date), "%Y%m%d")
  return(date)
}

# Create a new dataframe with the converted date from GEBDAT
# It takes about 10 seconds to process the data
# system.time: 
# user  system elapsed 
# 11.83    0.14   11.97 
GEBDAT2 <- as.data.frame(mydatefunc(data[,"GEBDAT"]))

# add dataframe as new variable to data
data <- cbind(data, GEBDAT2)

# 4. Fill missing GEBDAT is known within same id_2015
