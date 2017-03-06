---
title: "MIRROR data manipulation"
author: "Thijs Noordzij"
date: "05 november 2016"
output: html_document
---

# Open MIRROR-file from SPSS .sav file extension
## Require haven package
Haven package is faster than foreign package, and loads the data without error messages. Variable labels are stored in the "label" attribute of each variable.

Hadley Wickham and Evan Miller (2015). haven: Import SPSS, Stata and SAS Files. R package version 0.2.0. https://CRAN.R-project.org/package=haven


```{r}
if (!require("haven")){
  install.packages("haven")
  require("haven")
}

citation("haven")
```
  
## Load data
It takes almost 1 minute to load the data. 

```{r}
data <- read_spss("C:/Users/Thijs/Documents/MIRROR/data/mirror_formatie_ tm2014.sav")
```
The output of system.time() of previous code section:
 
|user|system|elapsed|
|-|-|-|
|40.72|0.33|41.08|


# Recoding missing values correctly

## Define NA in FUNGRP(_PVE1), BRIN, GEBDAT, GESLACHT

### FUNGRP

NA defined as in SPSS file for MIRROR provided by DUO. FUNGRP also has 2431 system.missings in SPSS. 
```{r}
missing_FUNGRP <- c(-1)
data$FUNGRP <- lapply(data$FUNGRP, function(x) replace(x, x %in% missing_FUNGRP, NA))
data$FUNGRP <- as.numeric(data$FUNGRP)
```

The output of system.time() of previous section of code:

|user|system|elapsed 
|-|-|-|
|29.65|0.13|29.92|

  
### FUNGRP_PVE
NA defined as in SPSS file for MIRROR provided by DUO. FUNGRP also has 2869 system.missings in SPSS. 
```{r}
missing_FUNGRP_PVE1 <- c(-1)
data$FUNGRP_PVE1 <- lapply(data$FUNGRP_PVE1, function(x) replace(x, x %in% missing_FUNGRP_PVE1, NA))
data$FUNGRP_PVE1 <- as.numeric(data$FUNGRP_PVE1)
```
  
### FUNGRP_FMIX1
NA defined as in SPSS file for MIRROR provided by DUO, and "-2" added. FUNGRP also has 8424 system.missings in SPSS. 
```{r}
missing_FUNGRP_FMIX1 <- c(-1, -2)
data$FUNGRP_FMIX1 <- lapply(data$FUNGRP_FMIX1, function(x) replace(x, x %in% missing_FUNGRP_FMIX1, NA))
data$FUNGRP_FMIX1 <- as.numeric(data$FUNGRP_FMIX1)
```
  
### BRIN
NA defined as in SPSS file for MIRROR provided by DUO.
```{r}
missing_BRIN <- c("O") 
data$BRIN <- lapply(data$BRIN, function(x) replace(x, x %in% missing_BRIN, NA))
data$BRIN <- as.character(data$BRIN)
```

The output of system.time() of previous section of code:

|user|system|elapsed|
|-|-|-|
|30.81|0.02|30.83|

There are many more unlikely, such as "O", "VMB", "0000", "P&O", "PR", "SB O", "STAF", "TEAM". In a [next section](#ValidateBRIN) this will be handled. 
  
### GEBDAT
NA defined as in SPSS file for MIRROR provided by DUO.
```{r}
missing_GEBDAT <- c(-1) 
data$GEBDAT <- lapply(data$GEBDAT, function(x) replace(x, x %in% missing_GEBDAT, NA))
```

The output of system.time() of previous section of code:

|user|system|elapsed|
|-|-|-|
|54.51|0.11|54.81|

  
### GESLACHT
NA defined as in SPSS file for MIRROR provided by DUO, "" (empty string) added. 
```{r}
missing_GESLACHT <- c("", "O") 
data$GESLACHT <- lapply(data$GESLACHT, function(x) replace(x, x %in% missing_GESLACHT, NA))
```

The output of system.time() of previous section of code:

|user|system|elapsed|
|-|-|-|
|30.50|0.06|30.60|

## Total missing values per variable
```{r}
sum(is.na(data$BRIN))
sum(is.na(data$GEBDAT))
sum(is.na(data$GESLACHT))
sum(is.na(data$FUNGRP))
sum(is.na(data$FUNGRP_PVE1))
sum(is.na(data$FUNGRP_FMIX1[data$JAAR >= 2002]))
```

|variable|missing values|comments|
|-|-|-|
|BRIN|1393||
|GEBDAT|4156||
|GESLACHT|4059|if " " is added as missing value, else 0|
|FUNGRP|10559|that includes 2431 system.missing in SPSS|
|FUNGRP_PVE1|9067|that includes 2869 system.missing in SPSS|
|FUNGRP_FMIX1|8424|number of NA in JAAR >= 2002. In JAAR < 2002 all values are NA|

## Validate BRIN {#ValidateBRIN}
BRIN is a unique identifier for a school. BRIN has a standard format: 4 characters, number, number, character, character (e.g. "11AO"). Some BRIN in the MIRROR-file do not represent the school where the staff (teacher or otherwise) works. These 'BRIN' represent staff working under direct responsibility of the board. These BRIN have a free format, which deviates from the previously mentioned standard format. Possibly, these BRIN are also not identical for the same school in different years.

valid.brin is a function that identifies (in)correct values for BRIN. This function is used to make a new variable in the data of the MIRROR-file (data$validbrin). valid.brin is sourced from a separate file. 

```{r}
source('E:/Google Drive/Promotie/Analyse/Teacher-attrition-with-MIRROR-data/validBRIN.R')
data$validbrin <- sapply(data$BRIN, valid.brin)
```
The validBRIN funtion works, but it takes ca. 35 minutes to complete the operation.


## Valid BRIN in complete dataset
```{r}
mytable <- table(data$validbrin, exclude = NULL)
mytable
prop.table(mytable)
```

||FALSE|TRUE|NA|
|-|-|-|-|
|n|42243|6407015|1393|
|proportion|0.0065486414|0.9932354114|0.0002159472|


## Valid BRIN per year
Invalid BRIN appear in 2008 and later years. It remains a small percentage of all observations, max 2%. In the following checks, only records of 2008 and later will be used. 

```{r}
mytable <- table(data$JAAR, data$validbrin, exclude = NULL)
mytable
prop.table(mytable,1)
```

## Valid BRIN per job (FUNGRP_PVE1 and FUNGRP_FMIX1)
Invalid BRIN are concentrated in non-teaching jobs, but are <5% of these records. For teachers, >99% of the records have a valid BRIN. This is checked for two different variables for job, with very similar results.  

```{r}
# FUNGRP_PVE1
mytable1 <- table(data$FUNGRP_PVE1[data$JAAR >= 2008], data$validbrin[data$JAAR >= 2008], exclude = NULL)
rownames(mytable1)<-c("Directie", "OP", "OOP", "OBP", "LIO", "<NA>")
mytable1
prop.table(mytable1,1)

# FUNGRP_FMIX1
mytable2 <- table(data$FUNGRP_FMIX1[data$JAAR >= 2008], data$validbrin[data$JAAR >= 2008], exclude = NULL)
rownames(mytable2)<-c("Directie", "OP", "OOP", "OBP", "LIO", "<NA>")
mytable2
prop.table(mytable2,1)

prop.table(mytable1,1) - prop.table(mytable2,1)
```

# Date variables
## convert numeric date variable to date
The GEBDAT variable in the MIRROR-file is a numeric variable. The first 4 characters represent year, the next 2 month, and the final 2 day. To convert this to a date variable, the numeric variable has to be converted to a string, which in turn can be converted to a date variable. 

```{r}
data$GEBDATdate <- sapply(data$GEBDAT, function(x) as.Date(toString(x), format = "%Y%m%d"))
class(data$GEBDATdate) <- "Date"
```

|user|system|elapsed|
|-|-|-|
|202.12|0.00|202.22|

## Create variable for reference date (Peildatum)
The JAAR variable contains the year of the record. The reference date is always the 1st of October. 

```{r}
data$refdate <- sapply(data$JAAR, function(x) as.Date(paste0(toString(x), "10", "01"), format = "%Y%m%d"))
class(data$refdate) <- "Date"
```

## Create variable for age at reference date
The function "age_years", developed by nzcoops (http://www.r-bloggers.com/updated-age-calculation-function/) is used to calculate the age of a person at the reference moment. 

```{r}
source('E:/Google Drive/Promotie/Analyse/Teacher-attrition-with-MIRROR-data/age calculation function.R')
data$age <- age_years(data$GEBDATdate, data$refdate)
```

# Potential problems with linking to other data
To link the teachers of this dataset reliable to other data, some key variables have to be complete. In most cases these variables are enough to identify persons: year (JAAR), school (BRIN), date of birth (GEBDAT), sex (GESLACHT), job (FUNGRP_PVE1). If a record has a missing value in one (or more) of these records, it is considered weak. In many cases, job might not be necessary for a reliable link, so a check with and without FUNGRP_PVE1 is done. 

13862 records (0.2%) have at least one missing value in the key variables necessary for linking, including the variable for job. If we exclude the variable for job, 5553 records (0.09%) with at least one missing key value remain. For further analysis in this paragraph, I use the more conservative estimate, which included the variable for job as source for potential problems with linking. 

```{r}
data$weaklink <- apply(data[, c("JAAR", "BRIN", "GEBDAT", "GESLACHT", "FUNGRP_PVE1")], 1, anyNA)
sum(data$weaklink)
sum(data$weaklink)/length(data$weaklink)
data$weaklink2 <- apply(data[, c("JAAR", "BRIN", "GEBDAT", "GESLACHT")], 1, anyNA)
sum(data$weaklink2)
sum(data$weaklink2)/length(data$weaklink2)
```

## Relation between 'weak' records and years {#weakyear}
Records with at least one missing key value seem to concentrate in the years 2008 and later. 2010 has the most, but still only ca. 1,5% of the records of that year. 

```{r}
mytable <- table(data$JAAR, data$weaklink, exclude = NULL)
mytable
prop.table(mytable, 1)
```

## Relation between 'weak' records and job
A large proportion of the weak records have missing values for job: 9067 out of 13862 weak records (65%) have a missing value for the job variable. The records that don't have a missing value for job are almost never weak (<0,1%), with a slightly higher proportion of weak records (0,2%) with the teachers in training (LIO). 

```{r}
mytable <- table(data$FUNGRP_PVE1, data$weaklink, exclude = NULL)
rownames(mytable)<-c("Directie", "OP", "OOP", "OBP", "LIO", "<NA>")
mytable
prop.table(mytable, 1)
```

The weak records in 2010 (2010 has the most weak records, [check here](#weakyear)) are also almost completely caused by a missing value for the job variable (and possibly also other missing values). 5959 out of the 6062 (98%) weak records in 2010 have a missing value for the job variable. 

```{r}
mytable <- table(data$FUNGRP_PVE1[data$JAAR==2010], data$weaklink[data$JAAR==2010], exclude = NULL)
rownames(mytable)<-c("Directie", "OP", "OOP", "OBP", "LIO", "<NA>")
mytable
prop.table(mytable, 1)
```

## Relation between 'weak' records and invalid BRIN
There seems to be no obvious link between the invalid BRIN and the missing key values. 86,7% of records with a missing key value have a valid BRIN and 3,2% have an invalid BRIN. The remaining 10% of the records with missing key values has a missing BRIN (<NA>), which makes sense because a missing BRIN is one of the criteria to mark a record as problematic. 

```{r}
mytable <- table(data$validbrin, data$weaklink, exclude = NULL)
mytable
prop.table(mytable, 2)
# mytable2 <- table(data$validbrin, data$weaklink)
# mytable2
# prop.table(mytable2, 2)
```


## constructing file on level of unique persons. Check for persons (id_2015) with one or more records with one or more NA's in variables used for linking to other data. 
### All records
Although only 0,2% of the records has NA's in variables important for linking to other data, when the records are aggregated to the level of individuals, 2,1% of the persons has at least one weak record. 

```{r}
if (!require("dplyr")){
  install.packages("dplyr")
  require("dplyr")
}

id_data <- data %>% 
  group_by(id_2015) %>% 
  summarise(weaklink_id = TRUE %in% weaklink)

sum(id_data$weaklink_id)
length(id_data$weaklink_id)
sum(id_data$weaklink_id)/length(id_data$weaklink_id)
```

For this analysis the dplyr package is used, citation: 
Hadley Wickham and Romain Francois (2015). dplyr: A Grammar of Data Manipulation. R package version 0.4.3. https://CRAN.R-project.org/package=dplyr

### Proportion of people with weak records per year 
In 2014 the problem of weak records per person seem limited. 510 out of 332418 (0,15%) of the persons (id_2014) have one or more weak records. In a longer period of time (2008-2014) 13004 out of 478643 the persons (2,7%) have one or more weak records. 

```{r}
id_data_20082014 <- ddply(subset(data, JAAR >= 2008), "id_2015", summarise, weaklink_id = max(weaklink))
sum(id_data_20082014$weaklink_id)
length(id_data_20082014$weaklink_id)
sum(id_data_20082014$weaklink_id)/length(id_data_20082014$weaklink_id)
```

Checking the proportion of weak records per person per year, we see the emergence of weak records starting in 2008. The years with the most persons with weak records are 2008 (1,0%) and 2010 (1,5%), less than 0,5% of the persons in all other years have weak records. 

```{r}
Year <- NULL
PersonsWeakRecords <- NULL
TotalPersons <- NULL
Proportion <- NULL

for (i in min(data$JAAR):max(data$JAAR)) {
  temp_id_data <- data %>% 
    filter(JAAR == i) %>% 
    group_by(id_2015) %>%
    summarise(weaklink_id = TRUE %in% weaklink)
  a <- sum(temp_id_data$weaklink_id)
  b <- length(temp_id_data$weaklink_id)
  Year <- c(Year, i)
  PersonsWeakRecords <- c(PersonsWeakRecords, a)
  TotalPersons <- c(TotalPersons, b)
  Proportion <- c(Proportion, a/b)
}

rm(a); rm(b); rm(i); rm(temp_id_data)
```

System.time for the previous section of code: 
   user  system elapsed 
 173.53    0.62  174.28 

```{r, Proportion of persons with weak records per year, echo=FALSE}
barplot(Proportion, names.arg = Year, ylab = "Proportion")
```

# Create variable for entry and exit into the labor force. 
Constructing a dataframe with aggregated data on level of persons (id_2015), making use of the dplyr package. The following code aggregates all contracts for teachers (FUNGRP_PVE1 == 2) in secondary ecuation (SECDJV == "WVO") in a dataframe with one record for every teacher. 

```{r}
if (!require("dplyr")){
  install.packages("dplyr")
  require("dplyr")
}
citation("dplyr")

if (!require("ggplot2")){
  install.packages("ggplot2")
  require("ggplot2")
}
citation("ggplot2")

id_data <- data %>% 
  filter(FUNGRP_PVE1 == 2) %>%
  filter(SECDJV == "WVO") %>%
  group_by(id_2015) %>% 
  summarise(
    min_year = min(JAAR, na.rm = TRUE), 
    max_year = max(JAAR, na.rm = TRUE), 
    # total_years_in_out = 1 + max(JAAR, na.rm = TRUE) - min(JAAR, na.rm = TRUE), 
    total_years_in_out = 1 + max_year - min_year, 
    age_in = min(age, na.rm = TRUE), 
    age_out = max(age, na.rm = TRUE), 
    weaklink_id = TRUE %in% weaklink 
)

xtabs(~ min_year + max_year, data = id_data, exclude = NULL, na.action = "na.pass")
xtabs(~ total_years_in_out, data = id_data, exclude = NULL, na.action = "na.pass")
qplot(id_data$age_in)
qplot(id_data$age_out)

# There is no way to establish what the first year as teacher was before the first year of the data, nor is there a way to establish what the last year as teacher was before the last year of the data. First and last years, and age at entry and exit cannot be established. These values are set to NA. 

id_data$min_year[id_data$min_year == min(data$JAAR, na.rm = TRUE)] <- NA  
id_data$max_year[id_data$max_year == max(data$JAAR, na.rm = TRUE)] <- NA  
id_data$age_in[is.na(id_data$min_year)] <- NA  
id_data$age_out[is.na(id_data$max_year)] <- NA  

id_data <- id_data %>% 
  mutate(
    total_years_in_out = 1 + max_year - min_year
    )

xtabs(~ min_year + max_year, data = id_data, exclude = NULL, na.action = "na.pass")
xtabs(~ total_years_in_out, data = id_data, exclude = NULL, na.action = "na.pass")
qplot(id_data$age_in)
qplot(id_data$age_out)

```

The following code aggregates all contracts per person per year in a dataframe. The dataframe only includes data on teachers (FUNGRP_PVE1 == 2) in secondary education (SECDJV == "WVO"). The dataframe includes a variable for the number of contract in that year, the age in that year and dummy variables for weak link. Arranging by OMVBTR_C ensures the largest contract is used for selecting school (BRIN) if a teacher works at more than one BRIN in one year. It takes approximately 2 minutes to run. 

```{r}
data <- arrange(data, id_2015, JAAR, OMVBTR_C)

id_data_year <- data %>% 
  filter(FUNGRP_PVE1 == 2) %>%
  filter(SECDJV == "WVO") %>%
  group_by(id_2015, JAAR) %>% 
  summarise(
    weaklink_id = TRUE %in% weaklink,
    n_contracts = n(), 
    age_year=max(age, na.rm = TRUE), 
    BRIN = max(BRIN)
  )

id_data_year$BRINJAAR <- paste0(id_data_year$BRIN, "_", id_data_year$JAAR)
```

Merge the two dataframes to get one dataframe with persons per year, with variables for first and last year of each person in the dataset. Add variables for experience, gap years and dummy variable for entry and exit year. 
```{r}
id_data_year <- left_join(id_data_year, id_data, by = "id_2015")
id_data_year <- id_data_year %>% 
  mutate(experience_current_in = (JAAR - min_year + 1))
id_data_year <- arrange(id_data_year, id_2015, JAAR)

id_data_year <- id_data_year %>%
  group_by(id_2015) %>% 
  mutate(sum_n_contracts = sum(n_contracts)) %>%
  mutate(years_in_data = row_number()) %>%
  mutate(gap_years = (experience_current_in - years_in_data))

id_data_year$first_year <- FALSE
id_data_year$first_year[id_data_year$JAAR == id_data_year$min_year] <- TRUE
id_data_year$first_year[is.na(id_data_year$min_year)] <- NA
id_data_year$last_year <- FALSE
id_data_year$last_year[id_data_year$JAAR == id_data_year$max_year] <- TRUE
id_data_year$last_year[is.na(id_data_year$max_year)] <- NA

table(id_data_year$experience_current_in, useNA = "ifany")
table(id_data_year$years_in_data, useNA = "ifany")
table(id_data_year$gap_years, useNA = "ifany")
table(id_data_year$first_year, useNA = "ifany")
table(id_data_year$last_year, useNA = "ifany")
table(id_data_year$first_year, id_data_year$JAAR, useNA = "ifany")
table(id_data_year$last_year, id_data_year$JAAR, useNA = "ifany")
```

Adding certification data
```{r}
## Certification data merge
if (!require("haven")){
  install.packages("haven")
  require("haven")
}

if (!require("dplyr")){
  install.packages("dplyr")
  require("dplyr")
}

if (!require("tidyr")){
  install.packages("tidyr")
  require("tidyr")
}

if (!require("xlsx")){
  install.packages("xlsx")
  require("xlsx")
}

certification <-read_spss("C:/Users/Thijs/Documents/MIRROR/data/HO bestand.sav")

teacher_training <- read.xlsx("C:/Users/Thijs/Documents/MIRROR/data/croho.xlsx", 1)
teacher_training <- teacher_training %>% fill(SUBCATEGORIEÃ.N)
teacher_training$CLUSTERCATORIEÃ.N[teacher_training$CLUSTERCATORIEÃ.N == " "] <- NA
teacher_training <- teacher_training %>% fill(CLUSTERCATORIEÃ.N)

teacher_training$teacher_vo <- grepl("leraar vo", teacher_training$SUBCATEGORIEÃ.N)

list_teacher_training <- teacher_training$CODE
list_vo_teacher_training <- teacher_training$CODE[teacher_training$teacher_vo == TRUE]

# ## Variable field of study
# print_labels(certification$criond) 
#   ## Value 1 has label Education
# prop.table(xtabs(~ certification$criond, data = certification))
#   ## 74.00% of the records is from a study in the field of education. 
#   ## Notable other fields: Behaviour and society (8.00%) and language and culture (7.12%). 
# 
# ## Variable subfield of study
# print_labels(certification$crisond) 
#   ## Values 0-4, 18 have labels related to teacher education
#   ## value                                                    label
#   ## 0                                        leraar basisonderwijs
#   ## 1                                           n.v.t. (onderwijs)
#   ## 2                             universitaire lerarenopleidingen
#   ## 3                        lerarenopleidingen speciaal onderwijs
#   ## 4 opleidingen tot leraar vo van de 1e graad in algemene vakken
#   ## 18               lerarenopleidingen op het gebied van de kunst
# 
# prop.table(xtabs(~ certification$crisond, data = certification[certification$criond == 1,]))
#   ## Many record from the field of study of education have other subfields of education than teacher education
#   ## 38.79% have label primary education teacher training (0), 
#   ## 22.60% lower secondary education teacher training (1), 
#   ## 1.56% universitairy teacher training program (upper secondary education) (2), 
#   ## 6.09% special education teacher training (3), 
#   ## 1.91% upper secondary education teacher training (4), 
# ## Decided to use Education (value 1 in variable criond) as field of study as proxy for teacher training. 

## Creating dataframe with certification information per teachers
certification$dipjaar[certification$dipjaar == 0] <- NA

a <- certification %>% group_by(id_2015) %>% summarise(startstudy = min(jaar))
prop.table(xtabs(~ startstudy, data = a, exclude = NULL, na.action = "na.pass"))

b <- certification %>% group_by(id_2015) %>% filter((diphbo > 1 & diphbo != 6) | (dipwo != 1)) %>% summarise(diploma = min(dipjaar, na.rm = TRUE))
prop.table(xtabs(~ diploma, data = b, exclude = NULL, na.action = "na.pass"))

c <- certification %>% filter(criact %in% list_teacher_training) %>% group_by(id_2015) %>% summarise(ed_startstudy = min(jaar))
prop.table(xtabs(~ ed_startstudy, data = c, exclude = NULL, na.action = "na.pass"))

d <- certification %>% filter(criact %in% list_teacher_training) %>% group_by(id_2015) %>% filter((diphbo > 1 & diphbo != 6) | (dipwo != 1)) %>% summarise(ed_diploma = min(dipjaar, na.rm = TRUE))
prop.table(xtabs(~ ed_diploma, data = d, exclude = NULL, na.action = "na.pass"))

e <- certification %>% filter(criact %in% list_vo_teacher_training) %>% group_by(id_2015) %>% summarise(vo_startstudy = min(jaar))
prop.table(xtabs(~ ed_startstudy, data = c, exclude = NULL, na.action = "na.pass"))

f <- certification %>% filter(criact %in% list_vo_teacher_training) %>% group_by(id_2015) %>% filter((diphbo > 1 & diphbo != 6) | (dipwo != 1)) %>% summarise(vo_diploma = min(dipjaar, na.rm = TRUE))
prop.table(xtabs(~ ed_diploma, data = d, exclude = NULL, na.action = "na.pass"))

## verschil hbo-wo
## hbo
g <- certification %>% group_by(id_2015) %>% filter(diphbo > 1 & diphbo != 6) %>% summarise(diploma_hbo = min(dipjaar, na.rm = TRUE))
h <- certification %>% filter(criact %in% list_teacher_training) %>% filter(!is.na(diphbo)) %>% group_by(id_2015) %>% summarise(ed_startstudy_hbo = min(jaar))
i <- certification %>% filter(criact %in% list_teacher_training) %>% filter(diphbo > 1 & diphbo != 6) %>% group_by(id_2015) %>% summarise(ed_diploma_hbo = min(dipjaar, na.rm = TRUE))
j <- certification %>% filter(criact %in% list_vo_teacher_training) %>% filter(!is.na(diphbo)) %>% group_by(id_2015) %>% summarise(vo_startstudy_hbo = min(jaar))
k <- certification %>% filter(criact %in% list_vo_teacher_training) %>% filter(diphbo > 1 & diphbo != 6) %>% group_by(id_2015) %>% summarise(vo_diploma_hbo = min(dipjaar, na.rm = TRUE))

## wo
l <- certification %>% group_by(id_2015) %>% filter(dipwo != 1) %>% summarise(diploma_wo = min(dipjaar, na.rm = TRUE))
m <- certification %>% filter(criact %in% list_teacher_training) %>% filter(!is.na(dipwo)) %>% group_by(id_2015) %>% summarise(ed_startstudy_wo = min(jaar))
n <- certification %>% filter(criact %in% list_teacher_training) %>% filter(dipwo != 1) %>% group_by(id_2015) %>% summarise(ed_diploma_wo = min(dipjaar, na.rm = TRUE))
o <- certification %>% filter(criact %in% list_vo_teacher_training) %>% filter(!is.na(dipwo)) %>% group_by(id_2015) %>% summarise(vo_startstudy_wo = min(jaar))
p <- certification %>% filter(criact %in% list_vo_teacher_training) %>% filter(dipwo != 1) %>% group_by(id_2015) %>% summarise(vo_diploma_wo = min(dipjaar, na.rm = TRUE))

id_certification <- full_join(a, 
                    full_join(b, 
                    full_join(c, 
                    full_join(d, 
                    full_join(e, 
                    full_join(f, 
                    full_join(g,
                    full_join(h,
                    full_join(i,
                    full_join(j,
                    full_join(k,
                    full_join(l,
                    full_join(m,
                    full_join(n,
                    full_join(o,
                    p
                    )))))))))))))))

rm(a); rm(b); rm(c); rm(d); rm(e); rm(f); 
summary(id_certification)
xtabs(~ ed_startstudy + ed_diploma, data = id_certification, exclude = NULL, na.action = "na.pass")
xtabs(~ vo_startstudy + vo_diploma, data = id_certification, exclude = NULL, na.action = "na.pass")


## Merging certification data in existing dataframes on teachers
for (i in colnames(id_certification)[-1]){
  id_data[i] <- NULL
  id_data_year[i] <- NULL
} 

id_data <- left_join(id_data, id_certification, by = "id_2015")
id_data_year <- left_join(id_data_year, id_certification, by = "id_2015")


## Create variables in id_data and id_data_year for certification at entry
# Certified teacher at entry
id_data$certified_start <- FALSE
id_data$certified_start[
  id_data$vo_diploma <= id_data$min_year] <- TRUE

id_data_year$certified_start <- FALSE
id_data_year$certified_start[
  id_data_year$vo_diploma <= id_data_year$min_year] <- TRUE

# Certified teacher within 2 years after entry (excludes certified teachers at entry)
id_data$certified_2year <- FALSE
id_data$certified_2year[
  (id_data$vo_diploma <= id_data$min_year + 2) & 
  (id_data$certified_start == FALSE)] <- TRUE

id_data_year$certified_2year <- FALSE
id_data_year$certified_2year[
  (id_data_year$vo_diploma <= id_data_year$min_year + 2) & 
  (id_data_year$certified_start == FALSE)] <- TRUE

# Certified teacher within 4 years after entry (excludes certified teachers at entry)
id_data$certified_4year <- FALSE
id_data$certified_4year[
  (id_data$vo_diploma <= id_data$min_year + 4) & 
  (id_data$certified_start == FALSE) & 
  (id_data$certified_2year == FALSE)] <- TRUE

id_data_year$certified_4year <- FALSE
id_data_year$certified_4year[
  (id_data_year$vo_diploma <= id_data_year$min_year + 4) & 
  (id_data_year$certified_start == FALSE) & 
  (id_data_year$certified_2year == FALSE)] <- TRUE

# Certified teacher at entry, but not for secondary education
id_data$certified_non_vo_start <- FALSE
id_data$certified_non_vo_start[
  (id_data$ed_diploma <= id_data$min_year) & 
  (id_data$certified_start == FALSE)] <- TRUE

id_data_year$certified_non_vo_start <- FALSE
id_data_year$certified_non_vo_start[
  (id_data_year$ed_diploma <= id_data_year$min_year) & 
  (id_data_year$certified_start == FALSE)] <- TRUE

# Non-teacher higher education completed at entry (excludes certified teachers at entry)
id_data$higher_ed_non_teacher <- FALSE
id_data$higher_ed_non_teacher[
  (id_data$diploma <= id_data$min_year) & 
  (id_data$certified_start == FALSE) & 
  (id_data$certified_non_vo_start == FALSE)] <- TRUE

id_data_year$higher_ed_non_teacher <- FALSE
id_data_year$higher_ed_non_teacher[
  (id_data_year$diploma <= id_data_year$min_year) & 
  (id_data_year$certified_start == FALSE) & 
  (id_data_year$certified_non_vo_start == FALSE)] <- TRUE

# Student teacher at entry (excludes certified teachers at entry)
id_data$student_teacher_start <- FALSE
id_data$student_teacher_start[
  (id_data$vo_startstudy <= id_data$min_year) & 
  (id_data$certified_start == FALSE)] <- TRUE

id_data_year$student_teacher_start <- FALSE
id_data_year$student_teacher_start[
  (id_data_year$vo_startstudy <= id_data_year$min_year) & 
  (id_data_year$certified_start == FALSE)] <- TRUE

# Student non-teacher at entry (excludes all student teachers and all completed higher education (certified teachers and non-certified teachers with higher education completed before entry))
id_data$student_non_teacher_start <- FALSE
id_data$student_non_teacher_start[
  (id_data$startstudy <= id_data$min_year) & 
  (id_data$student_teacher_start == FALSE) & 
  (id_data$certified_start == FALSE) & 
  (id_data$certified_non_vo_start == FALSE) & 
  (id_data$higher_ed_non_teacher == FALSE)] <- TRUE

id_data_year$student_non_teacher_start <- FALSE
id_data_year$student_non_teacher_start[
  (id_data_year$startstudy <= id_data_year$min_year) & 
  (id_data_year$student_teacher_start == FALSE) & 
  (id_data_year$certified_start == FALSE) & 
  (id_data_year$certified_non_vo_start == FALSE) & 
  (id_data_year$higher_ed_non_teacher == FALSE)] <- TRUE

###########################
id_data$certification_status <- "Unknown"
id_data_year$certification_status <- "Unknown"

# Student non-teacher at entry (excludes certified teachers and non-certified teachers with higher education completed before entry)
id_data$certification_status[
  (id_data$student_non_teacher_start == TRUE)] <- "Student non-teacher higher education, no diploma"

id_data_year$certification_status[
  (id_data_year$student_non_teacher_start == TRUE)] <- "Student non-teacher higher education, no diploma"

# Higher education completed at entry, non-teacher, non-student teacher (excludes certified teachers and student teachers)
id_data$certification_status[
  (id_data$higher_ed_non_teacher == TRUE)] <- "Non-teacher higher education diploma at entry, not in teacher training"

id_data_year$certification_status[
  (id_data_year$higher_ed_non_teacher == TRUE)] <- "Non-teacher higher education diploma at entry, not in teacher training"

# Teacher education completed at entry, but not for secondary education, non-student teacher (excludes certified teachers and student teachers)
id_data$certification_status[
  (id_data$certified_non_vo_start == TRUE)] <- "Non-teacher higher education diploma at entry, not in teacher training"

id_data_year$certification_status[
  (id_data_year$certified_non_vo_start == TRUE)] <- "Non-teacher higher education diploma at entry, not in teacher training"

# Student teacher at entry (excludes all certified teachers at entry and non-teacher higher education diploma)
id_data$certification_status[
  (id_data$student_teacher_start == TRUE) & 
  (id_data$certified_start == FALSE) & 
  (id_data$higher_ed_non_teacher == FALSE) & 
  (id_data$certified_non_vo_start == FALSE)] <- "Student teacher at entry, no higher education diploma"

id_data_year$certification_status[
  (id_data_year$student_teacher_start == TRUE) & 
  (id_data_year$certified_start == FALSE) &
  (id_data_year$higher_ed_non_teacher == FALSE) & 
  (id_data_year$certified_non_vo_start == FALSE)] <- "Student teacher at entry, no higher education diploma"


# Higher education completed at entry, non-teacher, student teacher (excludes certified teachers)
id_data$certification_status[
  (id_data$higher_ed_non_teacher == TRUE) & 
  (id_data$student_teacher_start == TRUE) & 
  (id_data$certified_non_vo_start == FALSE) & 
  (id_data$certified_start == FALSE)] <- "Student teacher at entry, non-teacher higher education diploma"

id_data_year$certification_status[
  (id_data_year$higher_ed_non_teacher == TRUE) & 
  (id_data_year$student_teacher_start == TRUE) & 
  (id_data_year$certified_non_vo_start == FALSE) & 
  (id_data_year$certified_start == FALSE)] <- "Student teacher at entry, non-teacher higher education diploma"

# Teacher education completed at entry, but not for secondary education, and also student teacher (only excludes teachers with certification for secondary education)
id_data$certification_status[
  (id_data$certified_non_vo_start == TRUE) & 
  (id_data$student_teacher_start == TRUE) & 
  (id_data$certified_start == FALSE)] <- "Student teacher at entry, also completed non-secondary education teacher training"

id_data_year$certification_status[
  (id_data_year$certified_non_vo_start == TRUE) & 
  (id_data_year$student_teacher_start == TRUE) & 
  (id_data_year$certified_start == FALSE)] <- "Student teacher at entry, also completed non-secondary education teacher training"
  
# Certified teacher at entry
id_data$certification_status[
  id_data$certified_start == TRUE] <- "Certified teacher at entry"

id_data_year$certification_status[
  id_data_year$certified_start == TRUE] <- "Certified teacher at entry"

# converting to factors + tables to check data transformations
id_data$certification_status <- as.factor(id_data$certification_status)
id_data_year$certification_status <- as.factor(id_data_year$certification_status)

xtabs(data = id_data, ~certification_status)
xtabs(data = id_data_year, ~certification_status)
```

Adding variables to indicate unlikely data (outliers in school data)
```{r}

```

Plotting age distribution per year of population of teachers, of leaving teachers, and of entering teachers (sector VO), Using ggplot2
```{r}
if (!require("ggplot2")){
  install.packages("ggplot2")
  require("ggplot2")
}
citation("ggplot2")

plot_age <- ggplot(id_data_year, aes())
plot_age + 
  geom_density(
    aes(age_year, color = "Teacher population")) + 
  # geom_density(
  #   data = id_data_year[id_data_year$JAAR == id_data_year$max_year,], 
  #   aes(age_year, color = "Teachers leaving profession")) + 
  # geom_density(
  #   data = id_data_year[id_data_year$JAAR == id_data_year$min_year,], 
  #   aes(age_year, color = "Teachers entering profession")) + 
  labs(x = "Age") + 
  facet_wrap(~ JAAR)

plot_age + 
  geom_density(
    aes(age_year, color = "Teacher population")) + 
  geom_density(
    data = id_data_year[id_data_year$JAAR == id_data_year$max_year,], 
    aes(age_year, color = "Teachers leaving profession")) + 
  geom_density(
    data = id_data_year[id_data_year$JAAR == id_data_year$min_year,], 
    aes(age_year, color = "Teachers entering profession")) + 
  labs(x = "Age") + 
  facet_wrap(~ certification_status)

## group by all categories of certification at start
# exit_entry_age <- 
#   id_data_year %>% 
#   group_by(certification_status, age_year) %>% 
#   summarise(n = n())
# 
# exit_entry_age <- full_join(exit_entry_age, 
#   id_data_year %>% 
#   filter(JAAR == min_year) %>% 
#   group_by(certification_status, age_year) %>% 
#   summarise(n_entry = n())
#   )
#   
# exit_entry_age <- full_join(exit_entry_age, 
#   id_data_year %>% 
#   filter(JAAR == max_year) %>% 
#   group_by(certification_status, age_year) %>% 
#   summarise(n_exit = n())
#   )

## group by certified teacher at start or not (corrected for unlikely data by multivariate measure)
## to-do: rerun creation of id_data(_year) and correctly add variables for outlyiness. 
exit_entry_age <- 
  id_data_year %>% 
  filter(outlier_mulitivar_BRIN == FALSE) %>%
  group_by(certified_start, age_year) %>% 
  summarise(n = n())

exit_entry_age <- full_join(exit_entry_age, 
  id_data_year %>% 
  filter(outlier_mulitivar_BRIN == FALSE) %>%
  filter(JAAR == min_year) %>% 
  group_by(certified_start, age_year) %>% 
  summarise(n_entry = n())
  )
  
exit_entry_age <- full_join(exit_entry_age, 
  id_data_year %>% 
  filter(outlier_mulitivar_BRIN == FALSE) %>%
  filter(JAAR == max_year) %>% 
  group_by(certified_start, age_year) %>% 
  summarise(n_exit = n())
  )

exit_entry_age_total <- 
  id_data_year %>% 
  filter(outlier_mulitivar_BRIN == FALSE) %>%
  group_by(age_year) %>% 
  summarise(n = n())

exit_entry_age$prop_entry <- exit_entry_age$n_entry / exit_entry_age$n
exit_entry_age$prop_exit <- exit_entry_age$n_exit / exit_entry_age$n
exit_entry_age_total$prop_entry <- exit_entry_age$n_entry / exit_entry_age$n
exit_entry_age_total$prop_exit <- exit_entry_age$n_exit / exit_entry_age$n

plot_age <- ggplot(exit_entry_age %>% filter(age_year > 22 & age_year < 45), aes())
plot_age + 
  geom_line(
    aes(age_year, prop_exit, 
    colour = certified_start)) + 
  labs(x = "Age", y = "proportion of teachers leaving profession", colour = "certified teacher at entry") 

plot_age <- ggplot(exit_entry_age_total %>% filter(age_year > 22 & age_year < 45), aes())
plot_age + 
  geom_line(
    aes(age_year, prop_exit)) + 
  labs(x = "Age", y = "proportion of teachers leaving profession", colour = "certified teacher at entry") 

##########
## Plot exit rate by experience year, grouped by certified teacher at start or not (not corrected for unlikely data)

exit_experience <- 
  id_data_year %>% 
  # filter(!is.na(min_year)) %>%
  # filter(!is.na(max_year)) %>%
  group_by(certified_start, experience_current_in) %>% 
  summarise(n = n())

exit_experience <- full_join(exit_experience, 
  id_data_year %>% 
  filter(!is.na(max_year)) %>%
  filter(JAAR == max_year) %>% 
  group_by(certified_start, experience_current_in) %>% 
  summarise(n_exit = n())
  )

exit_experience_total <- 
  id_data_year %>% 
  # filter(!is.na(min_year)) %>%
  # filter(!is.na(max_year)) %>%
  group_by(experience_current_in) %>% 
  summarise(n = n())
  
exit_experience_total <- full_join(exit_experience_total, 
  id_data_year %>% 
  # filter(!is.na(min_year)) %>%
  # filter(!is.na(max_year)) %>%
  filter(!is.na(max_year)) %>%
  filter(JAAR == max_year) %>% 
  group_by(experience_current_in) %>% 
  summarise(n_exit = n())
  )
  
exit_experience$prop_exit <- exit_experience$n_exit / exit_experience$n
exit_experience_total$prop_exit <- exit_experience_total$n_exit / exit_experience_total$n

plot_age <- ggplot(exit_experience %>% filter(), aes())
plot_age + 
  geom_line(
    aes(experience_current_in, prop_exit, colour = certified_start)) +
  geom_line(
    data = exit_experience_total,
    aes(experience_current_in, prop_exit)) + 
  labs(
    x = "Number of years since entry",
    y = "Proportion of teachers leaving profession",
    colour = "Certified teacher at entry")

#####
## Plot exit rate by experience year, grouped by certified teacher at start or not (corrected for unlikely data, DUO-definition)

exit_experience_corrected <- 
  id_data_year %>% 
  filter(outlier_DUO_BRIN == FALSE) %>%
  # filter(!is.na(min_year)) %>%
  # filter(!is.na(max_year)) %>%
  group_by(certified_start, experience_current_in) %>% 
  summarise(n = n())

exit_experience_corrected <- full_join(exit_experience_corrected, 
  id_data_year %>% 
  filter(outlier_DUO_BRIN == FALSE) %>%
  filter(!is.na(max_year)) %>%
  filter(JAAR == max_year) %>% 
  group_by(certified_start, experience_current_in) %>% 
  summarise(n_exit = n())
  )

exit_experience_corrected_total <- 
  id_data_year %>% 
  filter(outlier_DUO_BRIN == FALSE) %>%
  # filter(!is.na(min_year)) %>%
  # filter(!is.na(max_year)) %>%
  group_by(experience_current_in) %>% 
  summarise(n = n())
  
exit_experience_corrected_total <- full_join(exit_experience_corrected_total, 
  id_data_year %>% 
  filter(outlier_DUO_BRIN == FALSE) %>%
  # filter(!is.na(min_year)) %>%
  # filter(!is.na(max_year)) %>%
  filter(!is.na(max_year)) %>%
  filter(JAAR == max_year) %>% 
  group_by(experience_current_in) %>% 
  summarise(n_exit = n())
  )
  
exit_experience_corrected$prop_exit <- exit_experience_corrected$n_exit / exit_experience_corrected$n
exit_experience_corrected_total$prop_exit <- exit_experience_corrected_total$n_exit / exit_experience_corrected_total$n

plot_age <- ggplot(exit_experience_corrected %>% filter(), aes())
plot_age + 
  geom_line(
    aes(experience_current_in, prop_exit, 
    colour = certified_start)) +
  geom_line(
    data = exit_experience_corrected_total,
    aes(experience_current_in, prop_exit)) +
  labs(
    x = "Number of years since entry",
    y = "Proportion of teachers leaving profession",
    colour = "Certified teacher at entry")

## Compare exit rate with and without correction for unlikely data
plot_age_compare_correction <- ggplot(exit_experience_corrected %>% filter(), aes())
plot_age_compare_correction + 
  geom_line(
    aes(experience_current_in, prop_exit, colour = certified_start)) +
  geom_line(
    data = exit_experience,
    aes(experience_current_in, prop_exit, linetype = certified_start)) +
  # geom_line(
  #   data = exit_experience_corrected_total,
  #   aes(experience_current_in, prop_exit)) + 
  labs(
    x = "Number of years since entry",
    y = "Proportion of teachers leaving profession",
    colour = "Certified teacher at entry (corrected)", 
    linetype = "Certified teacher at entry (uncorrected)"
    )

#####
## Plot exit rate by experience year, grouped by certified teacher at start or not (corrected for unlikely data, multivariate-definition)

exit_experience_corrected <- 
  id_data_year %>% 
  filter(outlier_mulitivar_BRIN == FALSE) %>%
  # filter(!is.na(min_year)) %>%
  # filter(!is.na(max_year)) %>%
  group_by(certified_start, experience_current_in) %>% 
  summarise(n = n())

exit_experience_corrected <- full_join(exit_experience_corrected, 
  id_data_year %>% 
  filter(outlier_mulitivar_BRIN == FALSE) %>%
  filter(!is.na(max_year)) %>%
  filter(JAAR == max_year) %>% 
  group_by(certified_start, experience_current_in) %>% 
  summarise(n_exit = n())
  )

exit_experience_corrected_total <- 
  id_data_year %>% 
  filter(outlier_mulitivar_BRIN == FALSE) %>%
  # filter(!is.na(min_year)) %>%
  # filter(!is.na(max_year)) %>%
  group_by(experience_current_in) %>% 
  summarise(n = n())
  
exit_experience_corrected_total <- full_join(exit_experience_corrected_total, 
  id_data_year %>% 
  filter(outlier_mulitivar_BRIN == FALSE) %>%
  # filter(!is.na(min_year)) %>%
  # filter(!is.na(max_year)) %>%
  filter(!is.na(max_year)) %>%
  filter(JAAR == max_year) %>% 
  group_by(experience_current_in) %>% 
  summarise(n_exit = n())
  )
  
exit_experience_corrected$prop_exit <- exit_experience_corrected$n_exit / exit_experience_corrected$n
exit_experience_corrected_total$prop_exit <- exit_experience_corrected_total$n_exit / exit_experience_corrected_total$n

plot_age <- ggplot(exit_experience_corrected %>% filter(), aes())
plot_age + 
  geom_line(
    aes(experience_current_in, prop_exit,
    colour = certified_start)) +
  # geom_line(
  #   data = exit_experience_corrected_total,
  #   aes(experience_current_in, prop_exit)) +
  labs(
    x = "Number of years since entry",
    y = "Proportion of teachers leaving profession",
    colour = "Certified teacher at entry")

# write.csv2(exit_experience_corrected, "exit_experience_corrected.csv")

## Compare exit rate with and without correction for unlikely data (multivariate method)
plot_age_compare_correction <- ggplot(exit_experience_corrected %>% filter(), aes())
plot_age_compare_correction + 
  geom_line(
    aes(experience_current_in, prop_exit, colour = certified_start)) +
  geom_line(
    data = exit_experience,
    aes(experience_current_in, prop_exit, linetype = certified_start)) +
  # geom_line(
  #   data = exit_experience_corrected_total,
  #   aes(experience_current_in, prop_exit)) + 
  labs(
    x = "Number of years since entry",
    y = "Proportion of teachers leaving profession",
    colour = "Certified teacher at entry (corrected)", 
    linetype = "Certified teacher at entry (uncorrected)"
    )

```

```{r}
par(mfrow=c(4,4))

for (i in c(1998, 2003, 2008, 2013)){
  age_total <- id_data_year$age_year[id_data_year$JAAR == i]
  age_exit <- id_data_year$age_year[id_data_year$JAAR == i & id_data_year$max_year == i]
  age_entry <- id_data_year$age_year[id_data_year$JAAR == i & id_data_year$min_year == i]

  hist(age_total, ylim = c(0,3000), main = paste("Age of teachers in", i), xlab = "Age", breaks = min(id_data_year$age_year[id_data_year$JAAR == i], na.rm = TRUE):max(id_data_year$age_year[id_data_year$JAAR == i], na.rm = TRUE))
  hist(age_exit, ylim = c(0,700), main = paste("Age of teachers leaving the profession after", i), xlab = "Age", breaks = min(age_exit, na.rm = TRUE):max(age_exit, na.rm = TRUE))
  # hist(age_entry, ylim = c(0,500), main = paste("Age of teachers entering the profession in", i), xlab = "Age", breaks = min(age_entry, na.rm = TRUE):max(age_entry, na.rm = TRUE))

freq_age_total <- as.data.frame(table(age_total))
names(freq_age_total)[names(freq_age_total) == 'age_total'] <- 'Age'
names(freq_age_total)[names(freq_age_total) == 'Freq'] <- 'Freq_total'

freq_age_exit <- as.data.frame(table(age_exit))
names(freq_age_exit)[names(freq_age_exit) == 'age_exit'] <- 'Age'
names(freq_age_exit)[names(freq_age_exit) == 'Freq'] <- 'Freq_out'

freq_age_entry <- as.data.frame(table(age_entry))
names(freq_age_entry)[names(freq_age_entry) == 'age_entry'] <- 'Age'
names(freq_age_entry)[names(freq_age_entry) == 'Freq'] <- 'Freq_in'

mobility <- merge(freq_age_total, (merge(freq_age_exit, freq_age_entry)))
mobility$prop_out <- mobility$Freq_out / mobility$Freq_total
mobility$prop_in <- mobility$Freq_in / mobility$Freq_total

plot(mobility$Age, ylim = c(0, 0.80), mobility$prop_out, main = paste("Proportion of teachers leaving the profession, per age, in", i), ylab = "Proportion", xlab = "Age")
plot(mobility$Age, ylim = c(0, 0.35), xlim = c(0,35), mobility$prop_out, main = paste("Proportion of teachers leaving the profession, per age (<50), in", i), ylab = "Proportion", xlab = "Age")
# plot(mobility$Age, ylim = c(0, 1), mobility$prop_in, main = paste("Proportion of teachers entering the profession, per age, in", i), ylab = "Proportion", xlab = "Age")

write.csv2(mobility, paste0("E:/Google Drive/Promotie/Analyse/mobility", i, ".csv"))

rm(age_total); rm(age_exit); rm(age_entry)
rm(freq_age_total); rm(freq_age_exit); rm(freq_age_entry); rm(mobility)
rm(i)

}

```

Plotting experience distribution per year of population of teachers, of leaving teachers, and of entering teachers (sector VO). 
```{r}
par(mfrow=c(3, 2))

for (i in (2008:2013)){
  experience_total <- id_data_year$experience_year[id_data_year$JAAR == i]
  hist(experience_total, ylim = c(0,15000), main = paste("Experience of teachers in", i), xlab = "Years of experience", breaks = min(id_data_year$experience_year[id_data_year$JAAR == i], na.rm = TRUE):max(id_data_year$experience_year[id_data_year$JAAR == i], na.rm = TRUE))
  rm(experience_total)
  rm(i)
  }

for (i in (2008:2013)){
  experience_exit <- id_data_year$experience_year[id_data_year$JAAR == i & id_data_year$max_year == i]
  hist(experience_exit, ylim = c(0,3000), main = paste("Experience of teachers leaving the profession after", i), xlab = "Years of experience", breaks = min(experience_exit, na.rm = TRUE):max(experience_exit, na.rm = TRUE))
  rm(experience_exit)
  rm(i)
  }

for (i in (2008:2013)){
  experience_total <- id_data_year$experience_year[id_data_year$JAAR == i]
  freq_experience_total <- as.data.frame(table(experience_total))
  names(freq_experience_total)[names(freq_experience_total) == 'experience_total'] <- 'Experience'
  names(freq_experience_total)[names(freq_experience_total) == 'Freq'] <- 'Freq_total'
  
  experience_exit <- id_data_year$experience_year[id_data_year$JAAR == i & id_data_year$max_year == i]
  freq_experience_exit <- as.data.frame(table(experience_exit))
  names(freq_experience_exit)[names(freq_experience_exit) == 'experience_exit'] <- 'Experience'
  names(freq_experience_exit)[names(freq_experience_exit) == 'Freq'] <- 'Freq_out'
  
  mobility <- merge(freq_experience_total, freq_experience_exit)
  mobility$prop_out <- mobility$Freq_out / mobility$Freq_total
  
  plot(mobility$Experience, mobility$prop_out, ylim = c(0, 0.40), main = paste("Proportion of teachers leaving the profession, per experience, in", i), ylab = "Proportion", xlab = "Years of experience")
  
  write.csv2(mobility, paste0("E:/Google Drive/Promotie/Analyse/mobility_experience", i, ".csv"))
  
  age_experience <- table(id_data_year$age_year[id_data_year$JAAR == i], id_data_year$experience_year[id_data_year$JAAR == i])
  age_experience_prop <- prop.table(table(id_data_year$age_year[id_data_year$JAAR == i], id_data_year$experience_year[id_data_year$JAAR == i]))
  
  # write.csv2(age_experience, paste0("E:/Google Drive/Promotie/Analyse/age_experience_crosstab", i, ".csv"))
  # write.csv2(age_experience_prop, paste0("E:/Google Drive/Promotie/Analyse/age_experience_crosstab_prop", i, ".csv"))
  
  rm(experience_total); rm(experience_exit)
  rm(freq_experience_total); rm(freq_experience_exit); rm(mobility)
  rm(age_experience); rm(age_experience_prop)
  rm(i)
  
}

```


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
