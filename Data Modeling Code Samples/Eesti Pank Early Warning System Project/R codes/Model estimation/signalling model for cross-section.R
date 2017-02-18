signalling = function(crisis_file, indicator_file, lag = 0, sample = 'full', 
                      ncutoffs = 501, prefference = 0.5, visualize = FALSE){
  
  # upload packages
  library('dplyr')
  library('caTools')
  library('ggplot2')
  library('reshape')
  
  # set working directory and upload variables
  crisis = read.csv(paste0(crisis_file, '.csv'), as.is = TRUE)[1:185, ]
  indicator = read.csv(paste0(indicator_file, '.csv'), as.is = TRUE)[1:185, ]
  variables = c('crisis', 'indicator')
  names(crisis)[1] = 'date'
  names(indicator)[1] = 'date'
  
  # Select country group
  for(variable in variables){
    if(sample == 'full'){
      s = names(get(variable))
    } else if(sample == 'CEE'){
      s = c('date', 'Bulgaria', 'Croatia', 'Czech.Republic', 'Estonia', 'Hungary', 'Latvia', 'Lithuania', 'Poland', 'Romania', 'Slovakia', 'Slovenia')
      assign(variable, get(variable)[ , s])
    } else if(sample == 'WE'){
      s = c('date', 'Austria', 'Belgium', 'Denmark', 'Finland', 'France', 'Germany', 'Greece', 'Ireland', 'Italy', 'Netherlands', 'Portugal', 'Spain', 'Sweden', 'United.Kingdom')
      assign(variable, get(variable)[ , s])
    } else
      s = c('date', sample)
      assign(variable, get(variable)[ , s])
  }
  
  # Apply lag to indicator
  for(country in c(2:length(names(indicator)))){indicator[ , country] = lag(indicator[ , country], lag)}
  
  # Transform variables to panel
  for(variable in variables){
    temp = get(variable)
    names(temp)[1] = 'date'
    temp = melt(temp, id = 'date')
    assign(variable, temp[ , 3])
  }
  
  # Generate the number of observations
  nobs = nrow(indicator)
  
  # Create a vector that contains the threshold values to be tested
  T = rep(NA, ncutoffs)
  
  idobs = !is.na(indicator) & !is.na(crisis)
  indmax = max(indicator[idobs])
  indmin = min(indicator[idobs])
  T = seq(indmin, indmax, length.out = ncutoffs)
  output = list('Cutoffs' = T)
  
  # Determine the relevant sample size
  output$effectsmplsize = sum(idobs)
  
  # Determine the relevant sample
  ind = indicator[idobs]
  cri = crisis[idobs]
  
  # Create matrix shells to fill with the results for each threshold
  output$TP = rep(NA, ncutoffs)
  output$FP = rep(NA, ncutoffs)
  output$TN = rep(NA, ncutoffs)
  output$FN = rep(NA, ncutoffs)
  output$P1 = rep(NA, ncutoffs)
  output$P2 = rep(NA, ncutoffs)
  output$TPR = rep(NA, ncutoffs)
  output$TypeI = rep(NA, ncutoffs)
  output$TypeII = rep(NA, ncutoffs)
  output$NtS = rep(NA, ncutoffs)
  output$Loss = rep(NA, ncutoffs)
  output$Usefulness = rep(NA, ncutoffs)
  output$Usefulnessrel = rep(NA, ncutoffs)
  
  # Start a loop over all possible thresholds
  for(threshold in c(1:ncutoffs)){
    # Set true positives, false positives, true negatives, false negatives to zero
    TP = 0
    FP = 0
    TN = 0
    FN = 0
    
    # Loop over all the relevant observations
    for(observation in c(1:length(ind))){
      if(!is.na(ind[observation])){
        # Generate the signal
        if(ind[observation] > T[threshold]){
          S = TRUE
        } else {
          S = FALSE
        }
        # Determine relevant class of the signal
        if(cri[observation] == 1 & S){
          TP = TP + 1 # True Positive: there WAS crisis and there WAS signal
        }
        if(cri[observation] == 0 & S){
          FP = FP + 1 # False Positive: there was NO crisis but there WAS signal
        }
        if(cri[observation] == 0 & !S){
          TN = TN + 1 # True Negative: there was NO crisis and there was NO signal
        }
        if(cri[observation] == 1 & !S){
          FN = FN + 1 # False Negative: there WAS crisis and there was NO signal
        }
      }
    }
    # Fill the shells
    output$TP[threshold] = TP
    output$FP[threshold] = FP
    output$TN[threshold] = TN
    output$FN[threshold] = FN
    # Unconditional probability of crisis: number of crises / total number of periods
    output$P1[threshold] = (TP + FN) / (TP + FN + FP + TN) 
    # Unconditional probability of NO crisis: number of non-crises / total number of periods
    output$P2[threshold] = (FP + TN) / (TP + FN + FP + TN) 
    # True Positive Rate (Accuracy): number of correctly classified crises / number of crises
    # If 1: all happened crises classified correctly 
    # If 0: all happened crises classified incorrectly
    output$TPR[threshold] = TP / (TP + FN) 
    # Type I Error: number of incorrectly classified NON-crises / number of crises
    # If 1: all happened crises classified as NON-crises
    # If 0: all happened crises classified correctly
    output$TypeI[threshold] = FN / (TP + FN)
    # Type II Error: number of incorrectly classified crises / number of NON-crises
    # If 1: all happened NON-crises classified as crises
    # If 0: all happened crises classified correctly
    output$TypeII[threshold] = FP / (FP + TN)
    # Noise-to-Signal Ratio: Type II Error / True Positive Rate (or 1 - Type I Error)
    # If goes to 0: either Type II Error is relatively large or Accuracy is relatively small
    output$NtS[threshold] = (FP/(FP + TN)) / (TP / (TP + FN))
    # Loss of decision maker: sum of Type I and Type II errors weighted by the preferences towards each 
    output$Loss[threshold] = preference * output$TypeI[threshold] + (1 - preference) * output$TypeII[threshold]
    # Absolute Usefulness: 
    output$Usefulness[threshold] = min(preference, (1 - preference)) - output$Loss[threshold]
    # Relative Usefulness
    output$Usefulnessrel[threshold] = output$Usefulness[threshold] / min(preference, (1 - preference))
  }
  
  # Determine the optimum values
  minLoss = min(output$Loss)
  opt = match(min(output$Loss), output$Loss)
  
  output$thresholds = T[opt]
  output$optimum = list('TP' = output$TP[opt], 'FP' = output$FP[opt], 
                        'TN' = output$TN[opt], 'FN' = output$FN[opt],
                        'P1' = output$P1[opt], 'P2' = output$P2[opt], 'TPR' = output$TPR[opt],
                        'TypeI' = output$TypeI[opt], 'TypeII' = output$TypeII[opt], 
                        'NtS' = output$NtS[opt], 'Loss' = output$Loss[opt], 
                        'Usefulness' = output$Usefulness[opt], 'Usefulnessrel' = output$Usefulnessrel[opt])
  
  fprate = sort.int(output$TypeII, index.return = TRUE)$x
  indsort = sort.int(output$TypeII, index.return = TRUE)$ix
  output$Auroc = trapz(fprate, output$TPR[indsort])
  
  # visualize the results
  if(visualize == TRUE){
    output$results = data.frame('Crisis_Variable' = crisis_file, 'Indicator_Variable' = indicator_file,
                       'Lags' = lag, 'Number_of_Gridpoints' = ncutoffs, 'Threshold' = output$thresholds, 
                       'True_Positive' = output$optimum$TP, 'False_Positive' = output$optimum$FP,
                       'True_Negative' = output$optimum$TN, 'False_Negative' = output$optimum$FN,
                       'Unconditional_probability_of_crisis' = output$optimum$P1, 
                       'Unconditional_probability_of_NON_crisis' = output$optimum$P2,
                       'True_Positive_Rate' = output$optimum$TPR, 
                       'Type_I_Error' = output$optimum$TypeI, 'Type_II_Error' = output$optimum$TypeII,
                       'Noise_to_Signal_Ratio' = output$optimum$NtS, 'Loss' = output$optimum$Loss, 
                       'Absolute_Usefulness' = output$optimum$Usefulness, 
                       'Relative_Usefulness' = output$optimum$Usefulnessrel, 
                       'Area_Under_Receiver_Operating_Curve' = output$Auroc,
                       'Observations' = output$effectsmplsize)
    
    # Create a ROC plot
    plot = data.frame('FPR' = fprate, 'TPR' = output$TPR[indsort])
    auroc_label = paste('AUROC =', round(output$Auroc, 5))
    output$ROC = 
      ggplot(plot, aes(x = FPR, y = TPR)) + geom_line(colour = "salmon", size = 2) + 
      geom_abline(intercept = 0, slope = 1, linetype = 'dashed') + theme_bw() + 
      scale_x_continuous('False Positive Rate', expand = c(0,0)) + 
      scale_y_continuous('True Positive Rate', expand = c(0,0)) + 
      ggtitle(paste(indicator_file, 'ROC curve')) + 
      annotate('text', x = 0.2, y = 0.95, label = auroc_label, size = 5)
  }
  return(output)
}