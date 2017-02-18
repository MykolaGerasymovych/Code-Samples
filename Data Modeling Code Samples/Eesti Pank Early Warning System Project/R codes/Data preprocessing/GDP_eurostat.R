library('dplyr')
library('xlsx')

wd = 'C:/Users/kasutaja/Desktop/Useful/Crisis Leading Indicators/Data/GDP'
file = 'NGDP_eurostat_data.csv'
setwd(wd)
data = read.csv(file)

# remove thousands separators and convert values to numeric
data$Value = as.numeric(gsub(',', '', data$Value))

# select adjusted data
Adjdata = data[which(data$S_ADJ == 'Seasonally and calendar adjusted data'), ]

# select EU countries
Adjdata$GEO = gsub('(until 1990 former territory of the FRG)', '', Adjdata$GEO)
EU = c('Bulgaria',	'Estonia',	'Hungary',	'Latvia',	'Lithuania',	'Poland',	'Romania',	'Slovakia',	'Slovenia',	'Austria',	'Belgium',	'Croatia',	'Cyprus',	'Czech Republic',	'Denmark',	'Finland',	'France',	'Germany ()',	'Greece',	'Ireland',	'Italy',	'Luxembourg',	'Malta',	'Netherlands',	'Portugal',	'Spain',	'Sweden',	'United Kingdom')
EUdata = Adjdata[which(Adjdata$GEO %in% EU), ]

# check for countries
countries = unique(EUdata[2])

# separate data by units
EUdata = EUdata[ , c(1, 2, 3, 6)]
NGDP = EUdata[which(EUdata$UNIT == 'Current prices, million euro'), ]
RGDP = EUdata[which(EUdata$UNIT == 'Chain linked volumes (2010), million euro'), ]
IGDP = EUdata[which(EUdata$UNIT == 'Chain linked volumes, index 2010=100'), ]

# sort by country
NGDP = NGDP[order(NGDP$GEO, NGDP$TIME), ]
RGDP = RGDP[order(RGDP$GEO, RGDP$TIME), ]
IGDP = IGDP[order(IGDP$GEO, IGDP$TIME), ]

# make cross-section
# NGDP
labels = c('Time', EU)
csNGDP = unique(EUdata[1])
for(country in EU) {
  n = NGDP$Value[NGDP$GEO == country]
  csNGDP = cbind(csNGDP, n)
}
names(csNGDP) = labels

# RGDP
labels = c('Time', EU)
csRGDP = unique(EUdata[1])
for(country in EU) {
  n = RGDP$Value[RGDP$GEO == country]
  csRGDP = cbind(csRGDP, n)
}
names(csRGDP) = labels

# IGDP
labels = c('Time', EU)
csIGDP = unique(EUdata[1])
for(country in EU) {
  n = IGDP$Value[IGDP$GEO == country]
  csIGDP = cbind(csIGDP, n)
}
names(csIGDP) = labels

# generate csv files
path = "C:/Users/kasutaja/Desktop/Useful/Crisis Leading Indicators/Data/R processed/"
write.csv(csNGDP, paste(path, 'NGDP_clean_eurostat.csv', sep = '', na =''))
write.csv(csRGDP, paste(path, 'RGDP_clean_eurostat.csv', sep = '', na =''))
write.csv(csIGDP, paste(path, 'IGDP_clean_eurostat.csv', sep = '', na =''))