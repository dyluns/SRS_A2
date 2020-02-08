Main
================

``` r
set.seed(1)

library(logspline)
library(kedd)
```

Section II

Generate data for one-shot experiment

``` r
x1 <- rnorm(1000,0,1)
x2 <- rbeta(1000,2,3)

x3 <- numeric(1000)
for(i in seq_len(1000)) {
  z <- rbinom(1,1,0.5)
  if(z == 0) x3[i] <- rnorm(1,0,1)
  else x3[i] <- rbeta(1,2,3)
}
```

Scenario 1 - Normal(0,1)

``` r
#LSE(blue)
plot.logspline(logspline(x1), 
               col='blue', lwd=2, 
               xlab="Data", 
               ylab="Density")

#KDE(red)
bw_1 = h.ucv(x1, kernel='gaussian')
kde_1 <- density(x1, bw=bw_1$h)
lines(kde_1, col='red', lwd=2)

#True density(green)
lines(sort(x1),dnorm(sort(x1),0,1), col=3, lwd=2)

#Plot configuration
legend(x="topright",
       legend=c("LSE", "KDE", "True"),
       col=c("blue", "red", 3), 
       lwd=2, cex=1)
```

![](Main_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

Scenario 2 - Beta(2,3)

``` r
#LSE(blue)
plot.logspline(logspline(x2), 
               col='blue', lwd=2, 
               xlab="Data", 
               ylab="Density")

#KDE(red)
bw_2 = h.ucv(x2, kernel='gaussian')
kde_2 <- density(x2, bw=bw_2$h)
lines(kde_2, col='red', lwd=2)

#True density(green)
lines(sort(x2),dbeta(sort(x2),2,3), col=3, lwd=2)

#Plot configuration
legend(x="topright",
       legend=c("LSE", "KDE", "True"),
       col=c("blue", "red", 3), 
       lwd=2, cex=1)
```

![](Main_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

Scenario 3 - Mixed

``` r
#LSE(blue)
plot.logspline(logspline(x3), 
               col='blue', lwd=2, 
               xlab="Data", 
               ylab="Density")

#KDE(red)
bw_3 = h.ucv(x3, kernel='gaussian')
kde_3 <- density(x3, bw=bw_3$h)
lines(kde_3, col='red', lwd=2)

#True density(green)
mixed <- function(x) 0.5*dnorm(x,0,1) + 0.5*dbeta(x,2,3)
lines(sort(x3),mixed(sort(x3)), col=3, lwd=2)

#Plot configuration
legend(x="topright",
       legend=c("LSE", "KDE", "True"),
       col=c("blue", "red", 3), 
       lwd=2, cex=1)
```

![](Main_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->