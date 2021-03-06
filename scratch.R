library(kedd)
#library(locpol)
library(bayestestR)
library(logspline)

set.seed(1)
x=rpois(500,100)
#x=rbeta(500,1,3)
#x=rnorm(500,0,1)
#x=sample(1:10000, 500, replace=T)
y=density(x,kernel='gaussian')
bandwidth = h.ucv(x,kernel='gaussian')

lines(density(x,kernel='gaussian',bw = bandwidth$h))

h=hist(x,breaks = round((max(x)-min(x))/bandwidth$h),freq=FALSE)
#h$density
#plot(h$density)

h$density

plot.h.ucv(bandwidth)

#x2 = as.data.frame(x) 
#locpol(formula=z ~ x2 - 1,data=x2)

density_kernel <- estimate_density(x, method = "logspline")
lines(density_kernel$x, density_kernel$y, col = "red", lwd = 2)

plot.logspline(logspline(x),what='d')

summary.logspline(logspline(x))

lsx<-logspline(x)

mean(x)
lines(density(x),col = "blue")

lines( sort(x) , y = dbeta(sort(x),1,3) , col='red')

plot(dlogspline(x,lsx))

splxy=splinefun(density_kernel$x, density_kernel$y)
integrate(splxy,min(x),max(x))
plot(splxy)

plot(dpois(500,100))


library(SimCorrMix)

library("printr")
options(scipen = 999)
n <- 10000
mix_pis <- c(0.4, 0.6)
mix_mus <- c(-2, 2)
mix_sigmas <- c(1, 1)
mix_skews <- rep(0, 2)
mix_skurts <- rep(0, 2)
mix_fifths <- rep(0, 2)
mix_sixths <- rep(0, 2)
Nstcum <- calc_mixmoments(mix_pis, mix_mus, mix_sigmas, mix_skews, 
                          mix_skurts, mix_fifths, mix_sixths)

Nmix2 <- contmixvar1(n, "Polynomial", Nstcum[1], Nstcum[2]^2, mix_pis, mix_mus, 
                     mix_sigmas, mix_skews, mix_skurts, mix_fifths, mix_sixths)

fx <- function(x) 0.4 * dnorm(x, -2, 1) + 0.6 * dnorm(x, 2, 1)
plot_simpdf_theory(sim_y = Nmix2$Y_mix[, 1], ylower = -10, yupper = 10, 
                   title = "PDF of Mixture of Normal Distributions", fx = fx, lower = -Inf, 
                   upper = Inf)

x_3=Nmix2$Y_mix[, 1]

mixed <- function(x) 0.4 * rnorm(x, -2, 1) + 0.6 * rnorm(x, 2, 1)
z=mixed(500)
plot(density(z))

NUM.SAMPLES <- 5000
prices      <- numeric(NUM.SAMPLES)
for(i in seq_len(NUM.SAMPLES)) {
  z.i <- rbinom(1,1,0.5)
  if(z.i == 0) prices[i] <- rnorm(1, mean = 0, sd = 1)
  else prices[i] <- rbeta(1, 1,3)
}
plot(density(prices))

x <- seq(5, 15, length=1000)
y <- dnorm(x, mean=10, sd=3)
plot(x, y, type="l", lwd=1)

xx=x <- seq(-6,2, length=10000)
mixed <- function(x) 0.5*dnorm(x, 0,1 ) + 0.5*dbeta(x, 2,3)
plot(xx,mixed(xx),type="l")

plot(density(mixed(xx)))
