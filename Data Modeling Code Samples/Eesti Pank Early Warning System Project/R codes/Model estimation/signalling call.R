# define and set working directory, crisis and indicator variables and other parameters
wd = 'C:/Users/volodymyr/Desktop/Ready/'
setwd(wd)

crisis_file = 'Crises' # string name of crisis variable csv file without '.csv' 
indicator_file = 'LD'  # string name of indicator variable csv file without '.csv'
ncutoffs = 501         # number of indicator thresholds to go through
lag = 0                # number of periods to lag indicator by
sample = 'WE'          # string country group / vector of string coutries / 'full' for full sample
preference = 0.5       # decision maker's prefferens towards Type I error as opposed to Type II error
visualize = TRUE       # whether to create a table of results and ROC plot for the indicator

# call the signalling function
signal = signalling(crisis_file, indicator_file, lag, sample, 
                    ncutoffs, prefference, visualize)

# visualize the results
View(t(signal$results))
signal$ROC
