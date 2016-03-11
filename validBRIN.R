library(haven)  
data <- read_spss("C:/Users/Thijs/Documents/MIRROR/data/mirror_formatie_ tm2014.sav")

# Goal: Validate BRIN
# - Recode missing values to NA
# - Check if remainig values comply to rules of BRIN (string-string-integer-integer)
#
# Strategy:
#   - write function that identifies (in)correct values for BRIN
#   - use apply function on data['BRIN']

# function to identify correct BRIN (4 charcters: number, number, string, string)
valid.brin <- function(x) {
  #   print(paste0("Hi, I'm checking if ", x, " is a valid BRIN"))
  x <- as.character(x)
  if (nchar(x) != 4) {
    #     print("It's an invalid BRIN, it should be 4 characters long")
    return(FALSE)
  } else {
    #     print("It's possibly a valid BRIN, correct length of 4 characters")
  }
  y <- strsplit(x, '')
  for (i in (1:2)) {
    if (suppressWarnings(!is.na(as.numeric(y[[1]][i])))) {
      #       print(paste0('position ', i, ' is a number, part of a valid BRIN'))
    } else {
      #       print(paste0("position ", i, " should be a number but isn't"))
      #       print(paste0(x, " is not a valid BRIN"))
      return(FALSE)
    }
  }
  for (i in (3:4)) {
    if (suppressWarnings(is.na(as.numeric(y[[1]][i])))) {
      #       print(paste0('position ', i, ' is not a number, part of a valid BRIN'))
    } else {
      #       print(paste0("position ", i, " shouldn't be a number but is"))
      #       print(paste0(x, " is not a valid BRIN"))
      return(FALSE)
    }
    return(TRUE)
  }
}

# test valid.brin on single objects
# tmp <- "11AO"
# tmp2 <- "O"
# tmp3 <- "3333"
# tmp4 <- 2222
# valid.brin(tmp)   # TRUE
# valid.brin(tmp2)  # FALSE
# valid.brin(tmp3)  # FALSE
# valid.brin(tmp4)  # FALSE

# test valid.brin on subset of data['BRIN']
# FBRIN <- data[1:5000,'BRIN']
# y <- sapply(FBRIN, valid.brin)
# system.time(y <- sapply(FBRIN, valid.brin))
# user  system elapsed 
# 0.63    0.00    0.62 
# y
# class(y)  # "logical"
# sum(y)    # 4954
# length(y) # 5000
# length(y)-sum(y)  # 46 incorrect BRIN in first 5000 records

# apply valid.brin on complete data['BRIN']
# y <- sapply(data[,'BRIN'], valid.brin) # werkt, maar duurt lang
# y
# class(y)  # "logical"
# sum(y)    # 6407015
# length(y) # 6450651
# length(y)-sum(y)  # 43636 incorrect BRIN in all records (=0.0067645885663323)
