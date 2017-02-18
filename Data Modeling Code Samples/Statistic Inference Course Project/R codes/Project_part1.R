# initialize globals
set.seed(1)
lambda <- 0.2
sample_size <- 40
simulations <- 1000

# do 1000 simulations
simulated_expos <- matrix(rexp(simulations * sample_size, rate = lambda), simulations, sample_size)
averages <- rowMeans(simulated_expos)

# calculate mean of distribution of averages of 40 exponentials
mean(averages)

# calculate theoretical mean of distribution
1 / lambda

##  Show where the distribution is centered at and compare it to the theoretical center of the distribution.

# draw a histogram of averages
hist(averages, breaks=50, prob=TRUE, col = "yellow", 
     main="Averages distribution\nof exponential distribution samples",
     xlab="")
# density of the averages
lines(density(averages), col = "blue", lwd = 2)
# mean of averages of distribution
abline(v=mean(averages), col="blue", lwd = 4)
# theoretical center of distribution
abline(v=1/lambda, col="red", lwd = 2)
# theoretical density of the averages of samples
xfit <- seq(min(averages), max(averages), length=100)
yfit <- dnorm(xfit, mean=1/lambda, sd=(1/lambda/sqrt(sample_size)))
lines(xfit, yfit, pch=22, col="red", lty=2, lwd = 2)
# add legend
legend("topright", c("simulation", "theoretical"), 
       lty=c(1,2), lwd = c(2, 2), col=c("blue", "red"))

## Show how variable it is and compare it to the theoretical variance of the distribution.

# calculate standard deviation of distribution of averages of 40 exponentials
var(averages)

# calculate theoretical standard deviation of distribution
(1 / lambda) ^ 2 / sample_size

## Show that the distribution is approximately normal.

# compare the computed distribution density and the normal density 
qqnorm(averages, col = "blue"); qqline(averages, col = "red")
