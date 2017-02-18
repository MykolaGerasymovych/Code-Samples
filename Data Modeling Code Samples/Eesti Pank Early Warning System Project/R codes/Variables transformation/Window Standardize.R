library('dplyr')
library('xlsx')
library('rmngb')

# set working directory and read csv file
wd = 'C:/Users/kasutaja/Desktop/Useful/Crisis Leading Indicators/Data/Core Indicators/Clean/Dependent/'
file = 'NPL.xlsx'
sheet = 1

setwd(wd)
data = read.xlsx(file, sheet, stringsAsFactors=FALSE)[1:185, 1:29]

# standardize variables and create new table
t = 10 # set time window size
t1 = t + 1
std = data
for(c in c(2:length(names(data)))){
  try({
    v = data[!is.na(data[ , c]), c]
    st = rmAttr(scale(v[1:t]))
    for(n in c(t1:length(v))){
      m = n - t
      st[n] = rmAttr(scale(v[m:n]))[t1]
    }
    std[!is.na(std[ , c]), c] = st
  })
} 

# append table to xlsx file
write.xlsx(std, file, paste0('Window Standardized', as.character(t)), append = TRUE, showNA = FALSE, row.names = FALSE)