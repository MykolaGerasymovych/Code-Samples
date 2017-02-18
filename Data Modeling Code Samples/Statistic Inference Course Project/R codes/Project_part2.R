# load and look at the data
library("datasets")
data <- ToothGrowth
str(data)
head(data)

# preprocess data
data$dose <- as.factor(data$dose)

# get description statistics
summary(data)

# calculate variance of tooth length
var(data$len)

# plot the data
library("ggplot2")
ggplot(data = data, aes(x = as.factor(dose), y = len, col = supp)) +
        geom_point(stat = "identity") +
        facet_grid(. ~ supp) +
        xlab("Dose in miligrams") +
        ylab("Tooth length") +
        guides(fill = guide_legend(title = "Supplement type"))

# calculate mean and standard deviation for OJ factor
mean(data$len[which(data$supp == "OJ")])
sd(data$len[which(data$supp == "OJ")])

# calculate mean and standard deviation for VC factor
mean(data$len[which(data$supp == "VC")])
sd(data$len[which(data$supp == "VC")])

# make a linear model of tooth length by dose and supplement type factors
model <- lm(len ~ dose + supp, data = data)

# get a summary of the model and calculate 95% confidence intervals for coeficients
summary(model)
confint(model)

# visualize 95% confidence intervals for coeficients
library("sjPlot")
sjp.lm(model, title = "95% confidence intervals for dose and supplement type factors")
