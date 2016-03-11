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

# 5. Validate BRIN
# - Recode missing values to NA
# - Check if remainig values comply to rules of BRIN (string-string-integer-integer)

# Strategie:
#   - schrijf functie die waarde als (in)correct identificeert
#   - pas apply functie toe

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

tmp <- "11AO"
tmp2 <- "O"
tmp3 <- "3333"
tmp4 <- 2222
valid.brin(tmp)
valid.brin(tmp2)
valid.brin(tmp3)
valid.brin(tmp4)



str(data['BRIN'])
head(data['BRIN'])
data[1:50,'BRIN']
FBRIN <- data[1:50,'BRIN']
x <- FBRIN[1]
y <- strsplit(x, "")
FBRIN2 <- strsplit(FBRIN, "")
class((FBRIN[1])[3])
(x2[1])[[1]][1]
class(x)
x
(y)[1,1]
z <- as.data.frame(y)
z
FBRIN2[[45]][3]
class(FBRIN2[[45]][3]) == 'character'




l <- vector("list", length(FBRIN2))
i <- 0
for (br in FBRIN2){
  i <- i + 1
  l[[i]] <- (length(br))
  #   print(br)
  #   print(length(br))
  #   c(results, length(br)) # Geen lijst concatenate in een loop, zeer trage methode. 
  #   print(results)
  #       if (i < 6){
  #         print(i)
  #       }
}
print(i)
print(l)
head(l)
m <- as.numeric(l)
head(m)
str(m)

require(plyr)
require(qdap)
dist_tab(l)

# length(FBRIN2) werkt niet om het aantal observaties in een dataframe weer te geven. Gebruik nrow.
length(data['BRIN']) # is 1, waarom?
nrow(data['BRIN'])

z <- data['BRIN']
z <- data['BRIN'][1:10,]

for (br in z){
  print(br)
}

sapply(z[[1]], print)
as.matrix(z)

# l <- vector("list", (nrow(data['BRIN'])))
l <- vector("list", (nrow(z)))
i <- 0
for (br in z){
  i <- i + 1
  l[[i]] <- (length(br))
  #   print(br)
  #   print(length(br))
  #   c(results, length(br)) # Geen lijst concatenate in een loop, zeer trage methode. 
  #   print(results)
      if (i < 6){
        print(i)
      }
}
print(i)
print(l)
head(l)
m <- as.numeric(l)
head(m)
str(m)

require(plyr)
require(qdap)
dist_tab(l)

