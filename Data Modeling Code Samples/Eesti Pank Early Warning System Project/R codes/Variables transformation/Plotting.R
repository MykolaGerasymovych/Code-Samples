library('dplyr')
library('zoo')
library('xlsx')
library('ggplot2')

# define working directory and file details
wd = 'E:/Tartu/Eesti Pank/Useful/Crisis Leading Indicators/Data/Core Indicators/Clean/Dependent/'
file = 'NPL_std'
sheet = 1

# set working directory and upload files
setwd(wd)
crises = read.xlsx('E:/Tartu/Eesti Pank/Useful/Crisis Leading Indicators/Data/Core Indicators/Clean/Dependent/Crises.xlsx', 1, stringsAsFactors=FALSE)[1:185, 1:29]
npl_bv1 = read.xlsx('E:/Tartu/Eesti Pank/Useful/Crisis Leading Indicators/Data/Core Indicators/Clean/Dependent/NPLstd1_bv.xlsx', 1, stringsAsFactors=FALSE)[1:185, 1:29]
data = read.xlsx(paste0(file, '.xlsx'), sheet, stringsAsFactors=FALSE)[1:185, 1:29]

# plot variables and save to pdf
setwd('E:/Tartu/Eesti Pank/Useful/Crisis Leading Indicators/Data/R processed/plots')
pdf(paste(file, '_plots.pdf'))
for(c in c(2:length(names(data)))){
  try({
    plotdata = data.frame('date' = as.Date(yearmon(as.yearqtr(data$date, format = '%Y-Q%q')) + 2/12), 'var' = as.numeric(data[ , c]), 'crises' = as.numeric(crises[ , c]), 'npl' = as.numeric(npl_bv1[ , c]))
    plot = 
      ggplot(plotdata) + geom_line(aes(x = date, y = var, color = file), na.rm = TRUE) + theme_minimal() + 
      ylab(strsplit(file, '.csv')[[1]]) + xlab('date') + ggtitle(names(data)[c]) +
      geom_vline(aes(xintercept = npl, color = 'npl_bv'), size = 0.5, alpha = 0.9, show.legend = TRUE, na.rm = TRUE) + 
      geom_vline(aes(xintercept = crises, color = 'crises'), size = 0.5, alpha = 0.9, show.legend = TRUE, na.rm = TRUE) + 
      #geom_line(aes(x = date, y = as.numeric(npl[ , c])), color = 'grey', linetype = 'dashed', na.rm = TRUE) +
      geom_hline(yintercept = 0) + geom_hline(yintercept = 1, linetype = 'dashed') +
      scale_colour_manual(name = '', values = c('pink', 'paleturquoise1', 'blue')) +
      coord_cartesian(xlim = as.Date(data$date[!is.na(data[ , c])], origin = "1970-01-01"))
    
    bv = data.frame('date' = plotdata$date[!is.na(plotdata$var)]
    ggplot(plotdata) + 
      scale_x_date(limits = c(new_date[1], new_date[length(new_date)])) +
      geom_line(aes(x = date, y = var, color = file), na.rm = TRUE) + theme_minimal() + 
      ylab(strsplit(file, '.csv')[[1]]) + xlab('date') + ggtitle(names(data)[c]) +
      geom_vline(aes(xintercept = plotdata$date[which(plotdata$npl == 1)], color = 'npl_bv'), size = 0.5, alpha = 0.9, show.legend = TRUE, na.rm = TRUE) + 
      geom_vline(aes(xintercept = plotdata$date[which(plotdata$crises == 1)], color = 'crises'), size = 0.5, alpha = 0.9, show.legend = TRUE, na.rm = TRUE) + 
      #geom_line(aes(x = date, y = as.numeric(npl[ , c])), color = 'grey', linetype = 'dashed', na.rm = TRUE) +
      geom_hline(yintercept = 0) + geom_hline(yintercept = 1, linetype = 'dashed') +
      scale_colour_manual(name = '', values = c('pink', 'paleturquoise1', 'blue')) +
      coord_cartesian(xlim = as.Date(data$date[!is.na(data[ , c])], origin = "1970-01-01"))
    print(plot)
  })
}
dev.off()
