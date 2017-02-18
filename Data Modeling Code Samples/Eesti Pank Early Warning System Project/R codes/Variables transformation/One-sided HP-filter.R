library('dplyr')
library('xlsx')
library('mFilter')

# set working directory and read csv file
wd = 'C:/Users/kasutaja/Desktop/Useful/Crisis Leading Indicators/Data/Core Indicators/Clean/Finance/'
file = 'Real loans to NFS_full_ECB.xlsx'
sheet = 5

setwd(wd)
#data = read.csv(file, sep = ';', as.is = TRUE)
data = read.xlsx(file, sheet, stringsAsFactors=FALSE)[1:185, 1:29]
osgaps = data

# apply HP-filter and create a new table            
for(n in c(2: length(names(data)))){
  try({
    v = data[!is.na(data[ , n]), n]
    l_v = log(v) * 100
    osgap = hpfilter(l_v[1:5], freq = 1600, type = 'lambda')$cycle
    for(ob in 6:length(l_v)){
      osgap[ob] = hpfilter(l_v[1:ob], freq = 1600, type = 'lambda')$cycle[ob]
    }
    osgaps[!is.na(osgaps[ , n]), n] = osgap
  })
}

# append to xlsx file
write.xlsx(osgaps, file, 'OSGgap', append = TRUE, showNA = FALSE, row.names = FALSE)