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
