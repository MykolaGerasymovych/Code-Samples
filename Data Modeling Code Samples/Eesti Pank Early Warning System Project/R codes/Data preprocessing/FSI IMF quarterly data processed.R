library('dplyr')
library('xlsx')

wd = 'C:/Users/kasutaja/Desktop/Useful/Crisis Leading Indicators/Data/IMF data'
file = 'FSI_data_IMF.csv'
setwd(wd)
data = read.csv(file)

# construct quarterly data table
labels = data[ , c(1, 3, 5)]
Qs = select(data, contains('Q'))
Qdata = cbind(labels, Qs)
names(Qdata)[1] = 'Country.Name'

# select EU countries
EU = c('Bulgaria',	'Estonia',	'Hungary',	'Latvia',	'Lithuania',	'Poland',	'Romania',	'Slovak Republic',	'Slovenia',	'Austria',	'Belgium',	'Croatia',	'Cyprus',	'Czech Republic',	'Denmark',	'Finland',	'France',	'Germany',	'Greece',	'Ireland',	'Italy',	'Luxembourg',	'Malta',	'Netherlands',	'Portugal',	'Spain',	'Sweden',	'United Kingdom')
EUdata = Qdata[which(Qdata$Country.Name %in% EU), ]
names(EUdata) = gsub('X', '', names(EUdata))

# check for countries
countries = unique(EUdata[1])

# remove empty and constant rows
EUdata = EUdata[which(EUdata$Attribute == 'Value'), ]
nas = rep(0, length(EUdata[, 1]))
nas[1] = 'nas'
for(i in c(2: length(EUdata[ ,4]))) {
  sum = sum(EUdata[i, 4:length(EUdata[160, ])], na.rm = TRUE)
  if(sum == 0){nas[i] = 1}
}
EUdata = cbind(EUdata, nas)
neEUdata = EUdata[which(EUdata$nas ==0), ]

# export data to csv
path = "C:/Users/kasutaja/Desktop/Useful/Crisis Leading Indicators/Data/R processed/FSI_clean.csv"
write.csv(neEUdata, path, na ='')



# Extract NPL to Gross Loans
npl = neEUdata[which(neEUdata$Indicator.Name == 'Financial Soundness Indicators, Core Set, Deposit Takers, Asset Quality, Non-performing Loans to Total Gross Loans, Percent'), ]
npl = t(npl[ , -c(2, 3, length(npl[1, ]))])
path = "C:/Users/kasutaja/Desktop/Useful/Crisis Leading Indicators/Data/R processed/"
write.csv(npl, paste(path, 'IMF_NPL_FSI_clean.csv', na =''))

# Extract NPL EUR
nple = neEUdata[which(neEUdata$Indicator.Name == 'Financial Soundness Indicators, Core Set, Deposit Takers, Asset Quality, Non-performing Loans, Euros'), ]
nple = t(nple[ , -c(2, 3, length(nple[1, ]))])
path = "C:/Users/kasutaja/Desktop/Useful/Crisis Leading Indicators/Data/R processed/"
write.csv(nple, paste(path, 'IMF_NPL euro_FSI_clean.csv', na =''))