# Open MIRROR-file from SPSS .sav file extension

# haven package is faster than foreign package, and without error message. 
# Variable labels are stored in the "label" attribute of each variable.

# system.time: 
# user  system elapsed 
# 40.72    0.33   41.08 

# To do: 
# 1. How to get the value labels out of the SPSS-file?

# 2. Convert some variables to nominal variables (factor?)

# 3. Create date variable out of GEBDAT

# convert string date variable to date
data$GEBDATdate <- sapply(data$GEBDAT, function(x) as.Date(toString(x), format = "%Y%m%d"))
class(data$GEBDATdate) <- "Date"

# user  system elapsed 
# 213.00    0.07  213.45 

# 4. Fill missing GEBDAT is known within same id_2015
