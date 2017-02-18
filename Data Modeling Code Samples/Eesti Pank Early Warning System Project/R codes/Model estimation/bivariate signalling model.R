signalling = function(crisis_file, indicator_file1, indicator_file2, lag = 0, sample = 'full', 
                      ncutoffs = 501, prefference = 0.5, visualize = FALSE){
  
  # upload packages
  library('dplyr')
  library('caTools')
  library('ggplot2')
  library('reshape')
  
  # set working directory and upload variables
  crisis = read.csv(paste0(crisis_file, '.csv'), as.is = TRUE)[1:185, ]
  indicator1 = read.csv(paste0(indicator_file1, '.csv'), as.is = TRUE)[1:185, ]
  indicator2 = read.csv(paste0(indicator_file2, '.csv'), as.is = TRUE)[1:185, ]
  variables = c('crisis', 'indicator1', 'indicator2')
  
  # Select country group
  for(variable in variables){
    if(sample == 'full'){
      s = names(get(variable))
    } else if(sample == 'CEE'){
      s = c('date', 'Bulgaria', 'Estonia', 'Hungary', 'Latvia', 'Lithuania', 'Poland', 'Romania', 'Slovakia', 'Slovenia')
      assign(variable, get(variable)[ , s])
    } else if(sample == 'WE'){
      s = c('date', 'Austria', 'Belgium', 'Denmark', 'Finland', 'France', 'Germany', 'Greece', 'Ireland', 'Italy', 'Luxembourg', 'Netherlands', 'Portugal', 'Spain', 'Sweden', 'United.Kingdom')
      assign(variable, get(variable)[ , s])
    } else
      s = c('date', sample)
    assign(variable, get(variable)[ , s])
  }
  
  # Apply lag to indicator
  for(country in c(2:length(names(indicator1)))){indicator1[ , country] = lag(indicator1[ , country], lag)}
  for(country in c(2:length(names(indicator2)))){indicator2[ , country] = lag(indicator2[ , country], lag)}
  
  # Transform variables to panel
  for(variable in variables){
    temp = get(variable)
    names(temp)[1] = 'date'
    temp = melt(temp, id = 'date')
    assign(variable, temp[ , 3])
  }
  
  # Merge indicators
  indicator = cbind(indicator1, indicator2)
  
  # Generate the number of observations
  nind = ncol(indicator)
  nobs = nrow(indicator)
  
  # Create a vector that contains the threshold values to be tested
  T = matrix(NA, ncutoffs, nind)
  
  idobs = !is.na(indicator[ , 1]) & !is.na(indicator[ , 2]) & !is.na(crisis)
  for(indi in c(1:nind)){
    indmax = max(indicator[idobs, indi])
    indmin = min(indicator[idobs, indi])
    T[ , indi] = seq(indmin, indmax, length.out = ncutoffs)
  }
  output = list('Cutoffs' = T)
  
  # Determine the relevant sample size
  output$effectsmplsize = sum(idobs)
  
  # Determine the relevant sample
  ind = cbind(indicator[idobs, 1], indicator[idobs, 2])
  cri = crisis[idobs]
  output$correlation = cor(ind[ , 1], ind[ , 2], use = 'complete.obs')
  
  # Create matrix shells to fill with the results for each threshold
  output$TP = matrix(NA, ncutoffs, ncutoffs)
  output$FP = matrix(NA, ncutoffs, ncutoffs)
  output$TN = matrix(NA, ncutoffs, ncutoffs)
  output$FN = matrix(NA, ncutoffs, ncutoffs)
  output$P1 = matrix(NA, ncutoffs, ncutoffs)
  output$P2 = matrix(NA, ncutoffs, ncutoffs)
  output$TPR = matrix(NA, ncutoffs, ncutoffs)
  output$TypeI = matrix(NA, ncutoffs, ncutoffs)
  output$TypeII = matrix(NA, ncutoffs, ncutoffs)
  output$StN = matrix(NA, ncutoffs, ncutoffs)
  output$Loss = matrix(NA, ncutoffs, ncutoffs)
  output$Usefulness = matrix(NA, ncutoffs, ncutoffs)
  output$Usefulnessrel = matrix(NA, ncutoffs, ncutoffs)
  
  # Start a loop over all possible thresholds for indicator 1
  for(threshold1 in c(1:ncutoffs)){
    # Start a loop over all possible thresholds for indicator 2
    for(threshold2 in c(1:ncutoffs)){
      # Set true positives, false positives, true negatives, false negatives to zero
      TP = 0
      FP = 0
      TN = 0
      FN = 0
      
      # Loop over all the relevant observations
      for(observation in c(1:length(cri))){
        if(!(is.na(ind[observation, 1]) || is.na(ind[observation, 2]))){
          # Generate the signal
          if(ind[observation, 1] > T[threshold1, 1] && ind[observation, 2] > T[threshold2, 2]){
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
      output$TP[threshold1, threshold2] = TP
      output$FP[threshold1, threshold2] = FP
      output$TN[threshold1, threshold2] = TN
      output$FN[threshold1, threshold2] = FN
      # Unconditional probability of crisis: number of crises / total number of periods
      output$P1[threshold1, threshold2] = (TP + FN) / (TP + FN + FP + TN) 
      # Unconditional probability of NO crisis: number of non-crises / total number of periods
      output$P2[threshold1, threshold2] = (FP + TN) / (TP + FN + FP + TN) 
      # True Positive Rate (Accuracy): number of correctly classified crises / number of crises
      # If 1: all happened crises classified correctly 
      # If 0: all happened crises classified incorrectly
      output$TPR[threshold1, threshold2] = TP / (TP + FN) 
      # Type I Error: number of incorrectly classified NON-crises / number of crises
      # If 1: all happened crises classified as NON-crises
      # If 0: all happened crises classified correctly
      output$TypeI[threshold1, threshold2] = FN / (TP + FN)
      # Type II Error: number of incorrectly classified crises / number of NON-crises
      # If 1: all happened NON-crises classified as crises
      # If 0: all happened crises classified correctly
      output$TypeII[threshold1, threshold2] = FP / (FP + TN)
      # Signal-to-Noize Ratio: Type II Error / True Positive Rate (or 1 - Type I Error)
      # If goes to 0: either Type II Error is relatively large or Accuracy is relatively small
      output$StN[threshold1, threshold2] = (FP/(FP + TN)) / (TP / (TP + FN))
      # Loss of decision maker: sum of Type I and Type II errors weighted by the preferences towards each 
      output$Loss[threshold1, threshold2] = preference * output$TypeI[threshold1, threshold2] + (1 - preference) * output$TypeII[threshold1, threshold2]
      # Absolute Usefulness: 
      output$Usefulness[threshold1, threshold2] = min(preference, (1 - preference)) - output$Loss[threshold1, threshold2]
      # Relative Usefulness
      output$Usefulnessrel[threshold1, threshold2] = output$Usefulness[threshold1, threshold2] / min(preference, (1 - preference))
    }
  }
  
  # Determine the optimum values
  minLossInd = arrayInd(which.min(output$Loss), dim(output$Loss))
  threshold1_opt = minLossInd[1]
  threshold2_opt = minLossInd[2]
  
  output$thresholds = c(T[threshold1_opt, 1], T[threshold2_opt, 2])
  output$optimum = list('TP' = output$TP[threshold1_opt, threshold2_opt], 'FP' = output$FP[threshold1_opt, threshold2_opt], 
                        'TN' = output$TN[threshold1_opt, threshold2_opt], 'FN' = output$FN[threshold1_opt, threshold2_opt],
                        'P1' = output$P1[threshold1_opt, threshold2_opt], 'P2' = output$P2[threshold1_opt, threshold2_opt], 
                        'TPR' = output$TPR[threshold1_opt, threshold2_opt],
                        'TypeI' = output$TypeI[threshold1_opt, threshold2_opt], 'TypeII' = output$TypeII[threshold1_opt, threshold2_opt], 
                        'StN' = output$StN[threshold1_opt, threshold2_opt], 'Loss' = output$Loss[threshold1_opt, threshold2_opt], 
                        'Usefulness' = output$Usefulness[threshold1_opt, threshold2_opt], 
                        'Usefulnessrel' = output$Usefulnessrel[threshold1_opt, threshold2_opt])
  
  # Generate the AUROC
  if(ncutoffs <= 50){
    evalpoints = 5
    print('Evaluation points set to 5 ')
  } else if(ncutoffs <= 100){
    evalpoints = 25
    print('Evaluation points set to 25 ')
  } else
    evalpoints = 101
  
  # Vectorize matrices
  TPRv = melt(output$TPR)$value
  FPRv = melt(output$TypeII)$value
  
  # Sort unique FPRs and use index to restore pairs with TPR
  fprate = sort.int(FPRv, index.return = TRUE)$x
  indsort = sort.int(FPRv, index.return = TRUE)$ix
  tprate = TPRv[indsort]
  
  # Remove multiple FPR points
  Ufprate = unique(fprate)
  Uindsort = match(Ufprate, fprate)
  
  #Generate a shell for the ROC y-values (i.e. TP rates)
  roc = matrix(NA, length(Ufprate))
  
  # Compute exact/raw ROC-curve
  iold = 1
  for(ii in 1:length(Ufprate)){
    roc[ii] = max(tprate[c(iold:Uindsort[ii])])
    iold = Uindsort[ii] + 1
  }
  
  # Compute smoothed measure of the roc-curve
  UU = seq(min(Ufprate), max(Ufprate), length.out = evalpoints)
  ROCsmoothX = matrix(0, length(UU), 1)
  ROCsmoothY = matrix(0, length(UU), 1)
  ROCsmoothX[1] = Ufprate[1]
  ROCsmoothY[1] = roc[1]
  ROCsmoothX[length(ROCsmoothX)] = Ufprate[length(Ufprate)]
  ROCsmoothY[length(ROCsmoothY)] = roc[length(roc)]
  
  ComputeExactAUROC = 0
  for(ii in c(2:(length(UU)-1))){
    intFPR = match(Ufprate[Ufprate > UU[ii - 1] & Ufprate <= UU[ii]], Ufprate)
    if(is.null(intFPR)){
      print(paste('function bivAUROC: The set of unique grid points in the interval', as.character(round(UU[ii-1], 4)), ',',  as.character(round(UU[ii], 4)), 'is empty.'))
      print('Compute exact bivAUROC instead')
      ComputeExactAUROC = ComputeExactAUROC + 1  
    } else
      intFPRval = Ufprate[intFPR]
      ROCsmoothY[ii] = max(roc[intFPR])
      indTPR = match(max(roc[intFPR]), roc[intFPR])
      ROCsmoothX[ii] = intFPRval[indTPR]
  }
  
  # Save resuls and compute the AUROC
  output$Roc = roc
  output$RocSmooth = ROCsmoothY
  output$Auroc = trapz(Ufprate,roc)
  if(sum(ComputeExactAUROC) > 0){
    output$AurocSmooth = output$Auroc
  } else
    output$AurocSmooth = trapz(ROCsmoothX,ROCsmoothY)
  output$RocFPR = Ufprate
  output$RocSmoothFPR = ROCsmoothX
  
  # visualize the results
  if(visualize == TRUE){
    output$results = data.frame('Crisis_Variable' = crisis_file, 'Number_of_Gridpoints' = ncutoffs,
                                'Indicator_Variable_1' = indicator_file1, 'Threshold_1' = output$thresholds[1], 
                                'indicator_variable_2' = indicator_file2, 'Threshold_2' = output$thresholds[2],
                                'True_Positive' = output$optimum$TP, 'False_Positive' = output$optimum$FP,
                                'True_Negative' = output$optimum$TN, 'False_Negative' = output$optimum$FN,
                                'Unconditional_probability_of_crisis' = output$optimum$P1, 
                                'Unconditional_probability_of_NON_crisis' = output$optimum$P2,
                                'True_Positive_Rate' = output$optimum$TPR, 
                                'Type_I_Error' = output$optimum$TypeI, 'Type_II_Error' = output$optimum$TypeII,
                                'Signal_to_Noize_Ratio' = output$optimum$StN, 'Loss' = output$optimum$Loss, 
                                'Absolute_Usefulness' = output$optimum$Usefulness, 
                                'Relative_Usefulness' = output$optimum$Usefulnessrel, 
                                'Area_Under_Receiver_Operating_Curve' = output$Auroc,
                                'Area_Under_Receiver_Operating_Curve_Smooth' = output$AurocSmooth,
                                'Observations' = output$effectsmplsize, 'Correlation' = output$correlation)
    
    # Create a ROC plot
    plot = data.frame('FPR' = output$RocFPR, 'Roc' = output$Roc)
    plotSmooth = data.frame('FPR' = output$RocSmoothFPR, 'Roc' = output$RocSmooth)
    auroc_label1 = paste('AUROC =', round(output$Auroc, 5))
    auroc_label2 = paste('AUROC sm. =', round(output$AurocSmooth, 5))
    output$ROC = 
      ggplot(NULL, aes(x = FPR, y = Roc)) + geom_line(data = plot, colour = "salmon", size = 2) +
      geom_line(data = plotSmooth, colour = 'royalblue', size = 1) +
      geom_abline(intercept = 0, slope = 1, linetype = 'dashed') + theme_bw() + 
      scale_x_continuous('False Positive Rate', expand = c(0,0)) + 
      scale_y_continuous('True Positive Rate', expand = c(0,0)) + 
      ggtitle(paste(indicator_file1, 'and', indicator_file2, 'ROC curve')) + 
      annotate('text', x = 0.2, y = 0.95, label = auroc_label1, size = 5) + 
      annotate('text', x = 0.2, y = 0.9, label = auroc_label2, size = 5)
  }
  return(output)
}