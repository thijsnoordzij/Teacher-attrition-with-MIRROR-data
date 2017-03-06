## Codebook

## Set working directory
setwd("C:/Users/Thijs/Documents/MIRROR/workspace")


## Opening cleaned MIRROR-files made by CentERdata
if (!require("haven")){
  install.packages("haven")
  require("haven")
}
citation("haven")

data_VO <- read_dta("C:/Users/Thijs/Documents/MIRROR/data/formatie_s_nieuw2netto.dta")
data_VO_stroom <- read_dta("C:/Users/Thijs/Documents/MIRROR/data/stromen95_15.dta")


## Plotting age distribution per year of population of teachers, of leaving teachers, and of entering teachers (sector VO), Using ggplot2
if (!require("ggplot2")){
  install.packages("ggplot2")
  require("ggplot2")
}
citation("ggplot2")

plot_age <- ggplot(data_VO_stroom, aes())
plot_age + 
  geom_density(
    aes(lftd, color = "Teacher population")) + 
  geom_density(
    data = id_data_year,
    aes(age_year, color = "Teacher population")) + 
  # geom_density(
  #   data = data_VO_stroom[data_VO_stroom$JAAR == data_VO_stroom$max_year,], 
  #   aes(age_year, color = "Teachers leaving profession")) + 
  # geom_density(
  #   data = data_VO_stroom[data_VO_stroom$JAAR == data_VO_stroom$min_year,], 
  #   aes(age_year, color = "Teachers entering profession")) + 
  labs(x = "Age") + 
  facet_wrap(~ jaar)
