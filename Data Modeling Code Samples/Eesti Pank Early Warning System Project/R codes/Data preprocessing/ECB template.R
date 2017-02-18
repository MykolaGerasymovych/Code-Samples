library('dplyr')
library('xlsx')

# set working directory and read csv file
wd = 'C:/Users/kasutaja/Desktop/Useful/Crisis Leading Indicators/Data/ECB SDW data/Useful/'
file = 'Interest rates for loans for house purchases, 1 to 5.csv'
setwd(wd)
data = read.csv(file, sep = ';', as.is = TRUE)

# preprocess data
data = data[ , c(1, 3, length(data[1, ]))]
names(data) = c('time', 'value', 'country')
data = data[order(data$country, data$time), ]

# select only quarterly values
data$time = gsub('03$', 'Q1', data$time)
data$time = gsub('06$', 'Q2', data$time)
data$time = gsub('09$', 'Q3', data$time)
data$time = gsub('12$', 'Q4', data$time)
data = data[grep('Q', data$time), ]

# select EU countries and make cross section
EU = c('Bulgaria',	'Estonia',	'Hungary',	'Latvia',	'Lithuania',	'Poland',	'Romania',	'Slovakia',	'Slovenia',	'Austria',	'Belgium',	'Croatia',	'Cyprus', 'Czech Republic',	'Denmark',	'Finland',	'France',	'Germany',	'Greece',	'Ireland',	'Italy',	'Luxembourg',	'Malta',	'Netherlands',	'Portugal',	'Spain',	'Sweden',	'United Kingdom')
table = read.csv('C:/Users/kasutaja/Desktop/Useful/Crisis Leading Indicators/Data/Core Indicators/Blank.csv', sep = ';')
for(c in EU){
  print(c)
  s = as.numeric(rep(NA, length(table$X)))
  try({v = data[grep(c, data$country), ]
    beg = match(v[1, 1], table[, 1])
    end = beg + length(v$time) - 1
    s[beg:end] = as.numeric(v$value)})
  col = match(c, EU) + 1
  table[ , col] = s
} 

# generate csv file
path = "C:/Users/kasutaja/Desktop/Useful/Crisis Leading Indicators/Data/R processed/"
write.csv(table, paste0(path, 'ECB_', file, na =''))