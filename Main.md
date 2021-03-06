Main
================

``` r
library(FNN)
library(ggplot2)
```

``` r
bw.ucv.mod <- function(x, nb = 1000L,
                       h_grid = diff(range(x)) * (seq(0.1, 1, l = 200))^2,
                       plot_cv = FALSE) {
  if ((n <- length(x)) < 2L)
    stop("need at least 2 data points")
  n <- as.integer(n)
  if (is.na(n))
    stop("invalid length(x)")
  if (!is.numeric(x))
    stop("invalid 'x'")
  nb <- as.integer(nb)
  if (is.na(nb) || nb <= 0L)
    stop("invalid 'nb'")
  storage.mode(x) <- "double"
  hmax <- 1.144 * sqrt(var(x)) * n^(-1/5)
  Z <- .Call(stats:::C_bw_den, nb, x)
  d <- Z[[1L]]
  cnt <- Z[[2L]]
  fucv <- function(h) .Call(stats:::C_bw_ucv, n, d, cnt, h)
  ## Original
  # h <- optimize(fucv, c(lower, upper), tol = tol)$minimum
  # if (h < lower + tol | h > upper - tol)
  #   warning("minimum occurred at one end of the range")
  ## Modification
  obj <- sapply(h_grid, function(h) fucv(h))
  h <- h_grid[which.min(obj)]
  if (plot_cv) {
    plot(h_grid, obj, type = "o")
    rug(h_grid)
    abline(v = h, col = 2, lwd = 2)
  }
  h
}
```

Section II

Generate data for one-shot experiment

``` r
set.seed(1)

x1 <- rgamma(1000,5,1)
x2 <- rnorm(1000,0,0.1)

x3 <- numeric(1000)
for(i in seq_len(1000)) {
  z <- rbinom(1,1,0.5)
  if(z == 0) x3[i] <- rnorm(1,-1,1)
  else x3[i] <- rnorm(1,2,1)
}

xs1 <- sort(x1)
xs2 <- sort(x2)
xs3 <- sort(x3)
```

Scenario 1 - Gamma(5,1)

``` r
set.seed(1)

#KNN(blue)
k1full <- numeric(10)
for(j in 1:10){
  x <- rgamma(1000,5,1)
  ise <- numeric(491)
  for(i in 10:500){
    knn <- knn.dist(x,i)
    fknn <- i/(2*1000*knn[,i])
    fse <- splinefun(x, (fknn-dgamma(x,5,1))^2)
    ise[i-9] <- integrate(fse, min(x), max(x), subdivisions=2000)$value
  }
  k1full[j] <- which.min(ise) + 9
}
k_1 <- round(mean(k1full))

knn_1 <- knn.dist(xs1,k_1)
fknn_1 <- k_1/(2*1000*knn_1[,k_1])
contfknn_1 <- splinefun(xs1, fknn_1)
plot(contfknn_1, col='blue',lwd=2,
     ylim=c(0,0.22),
     xlim=c(0,12),
     xlab="X", 
     ylab="Density",
     cex.lab=1.5,
     main='Fig.1 - Gamma(5, 1)')

#KDE(red)
bw_1 <- bw.ucv.mod(xs1)
kde_1 <- density(xs1, bw=bw_1)
lines(kde_1, col='red', lwd=2)

#True density(green)
lines(xs1,dgamma(xs1,5,1), col=3, lwd=2)

#Plot configuration
legend(x="topright",
       legend=c("KNDE", "KDE", "True"),
       col=c("blue", "red", 3), 
       lwd=2, cex=1)
```

![](Main_files/figure-gfm/Sc1-1.png)<!-- -->

Scenario 2 - Normal(0,0.01)

``` r
set.seed(1)

#KNN(blue)
k2full <- numeric(10)
for(j in 1:10){
  x <- rnorm(1000,5,1)
  ise <- numeric(491)
  for(i in 10:500){
    knn <- knn.dist(x,i)
    fknn <- i/(2*1000*knn[,i])
    fse <- splinefun(x, (fknn-dnorm(x,1,0.1))^2)
    ise[i-9] <- integrate(fse, min(x), max(x), subdivisions=2000)$value
  }
  k2full[j] <- which.min(ise) + 9
}
k_2 <- round(mean(k2full))

knn_2 <- knn.dist(xs2,k_2)
fknn_2 <- k_2/(2*1000*knn_2[,k_2])
contfknn_2 <- splinefun(xs2, fknn_2)
plot(contfknn_2, col='blue',lwd=2,
     ylim=c(0.2,4.2),
     xlim=c(-1,1),
     xlab="X", 
     ylab="Density",
     cex.lab=1.5,
     main='Fig.2 - Normal(0, 0.01)')

#KDE(red)
bw_2 <- bw.ucv.mod(xs2)
kde_2 <- density(xs2, bw=bw_2)
lines(kde_2, col='red', lwd=2)

#True density(green)
lines(xs2,dnorm(xs2,0,0.1), col=3, lwd=2)

#Plot configuration
legend(x="topright",
       legend=c("KNDE", "KDE", "True"),
       col=c("blue", "red", 3), 
       lwd=2, cex=1)
```

![](Main_files/figure-gfm/Sc2-1.png)<!-- -->

Scenario 3 - Mixed

``` r
set.seed(1)

mixed <- function(x) 0.5*dnorm(x,-1,1) + 0.5*dnorm(x,2,1)

#KNN(blue)
k3full <- numeric(10)
for(j in 1:10){
  x <- numeric(1000)
  for(k in seq_len(1000)) {
    z <- rbinom(1,1,0.5)
    if(z == 0) x[k] <- rnorm(1,-1,1)
    else x[k] <- rnorm(1,2,1)
  }
  ise <- numeric(491)
  for(i in 10:500){
    knn <- knn.dist(x,i)
    fknn <- i/(2*1000*knn[,i])
    fse <- splinefun(x, (fknn-mixed(x))^2)
    ise[i-9] <- integrate(fse, min(x), max(x), subdivisions=2000)$value
  }
  k3full[j] <- which.min(ise) + 9
}
k_3 <- round(mean(k3full))

knn_3 <- knn.dist(xs3,k_3)
fknn_3 <- k_3/(2*1000*knn_3[,k_3])
contfknn_3 <- splinefun(xs3, fknn_3)
plot(contfknn_3, col='blue',lwd=2,
     ylim=c(0,0.25),
     xlim=c(-5,5),
     xlab="X", 
     ylab="Density",
     cex.lab=1.5,
     main='Fig.3 - Mixed')

#KDE(red)
bw_3 <- bw.ucv.mod(xs3)
kde_3 <- density(xs3, bw=bw_3)
lines(kde_3, col='red', lwd=2)

#True density(green)
lines(xs3,mixed(xs3), col=3, lwd=2)

#Plot configuration
legend(x="topright",
       legend=c("KNDE", "KDE", "True"),
       col=c("blue", "red", 3), 
       lwd=2, cex=1)
```

![](Main_files/figure-gfm/Sc3-1.png)<!-- -->

Section III

``` r
N1<-250
N2<-500
N3<-1000
```

Scenario 1, N=250

``` r
set.seed(1)
x11 <- sort(rgamma(N1,5,1))

k11full <- numeric(10)
for(j in 1:10){
  x <- rgamma(250,5,1)
  ise <- numeric(116)
  for(i in 10:125){
    knn <- knn.dist(x,i)
    fknn <- i/(2*250*knn[,i])
    fse <- splinefun(x, (fknn-dgamma(x,5,1))^2)
    ise[i-9] <- integrate(fse, min(x), max(x), subdivisions=2000)$value
  }
  k11full[j] <- which.min(ise) + 9
}
k11 <- round(mean(k11full))

ise_knn11_full <- numeric(1000)
ise_kde11_full <- numeric(1000)

for(i in 1:1000){
  x11 <- rgamma(N1,5,1)
  
  knn11 <- knn.dist(x11,k11)
  dknn11 <- k11/(2*250*knn11[,k11])
  
  bw11 <- bw.ucv.mod(x11)
  kde11 <- density(x11, bw=bw11)
  dkde11 <- kde11$y
  
  se_knn11 <- splinefun(x11, (dknn11-dgamma(x11,5,1))^2)
  ise_knn11 <- integrate(se_knn11, min(x11), max(x11))$value
  ise_knn11_full[i] <- ise_knn11
  
  se_kde11 <- splinefun(kde11$x, (dkde11-dgamma(kde11$x,5,1))^2)
  ise_kde11 <- integrate(se_kde11, min(x11), max(x11))$value
  ise_kde11_full[i] <- ise_kde11
}

knn11df <- data.frame('ISE'=ise_knn11_full)
kde11df <- data.frame('ISE'=ise_kde11_full)
knn11df$Estimator <- 'KNDE'
kde11df$Estimator <- 'KDE'
df11 <- rbind(knn11df,kde11df)

ggplot(df11, aes(x=Estimator, 
                 y=ISE, 
                 fill=Estimator)) + 
  geom_boxplot() +
  labs(y = "ISE", 
       title = "Fig.4.1 - Scenario 1, N=250"
       ) +
  theme(plot.title = element_text(size = 20, hjust = 0.5),
        axis.text.x = element_text(size = 15),
        axis.text.y = element_text(size = 15),
        axis.title.x=element_blank(),
        axis.title.y = element_text(size = 20),
        legend.position = "none",
        plot.margin = unit(c(0,0,0,0),"cm"))
```

![](Main_files/figure-gfm/S1N1-1.png)<!-- -->

Scenario 1, N=500

``` r
set.seed(1)
x12 <- rgamma(N2,5,1)

k12full <- numeric(10)
for(j in 1:10){
  x <- rgamma(500,5,1)
  ise <- numeric(241)
  for(i in 10:250){
    knn <- knn.dist(x,i)
    fknn <- i/(2*500*knn[,i])
    fse <- splinefun(x, (fknn-dgamma(x,5,1))^2)
    ise[i-9] <- integrate(fse, min(x), max(x), subdivisions=2000)$value
  }
  k12full[j] <- which.min(ise) + 9
}
k12 <- round(mean(k12full))

ise_knn12_full <- numeric(1000)
ise_kde12_full <- numeric(1000)

for(i in 1:1000){
  x12 <- rgamma(N2,5,1)
  
  knn12 <- knn.dist(x12,k12)
  dknn12 <- k12/(2*500*knn12[,k12])
  
  bw12 <- bw.ucv.mod(x12)
  kde12 <- density(x12, bw=bw12)
  dkde12 <- kde12$y
  
  se_knn12 <- splinefun(x12, (dknn12-dgamma(x12,5,1))^2)
  ise_knn12 <- integrate(se_knn12, min(x12), max(x12), subdivisions=2000)$value
  ise_knn12_full[i] <- ise_knn12
  
  se_kde12 <- splinefun(kde12$x, (dkde12-dgamma(kde12$x,5,1))^2)
  ise_kde12 <- integrate(se_kde12, min(x12), max(x12))$value
  ise_kde12_full[i] <- ise_kde12
}

knn12df <- data.frame('ISE'=ise_knn12_full)
kde12df <- data.frame('ISE'=ise_kde12_full)
knn12df$Estimator <- 'KNDE'
kde12df$Estimator <- 'KDE'
df12 <- rbind(knn12df,kde12df)

ggplot(df12, aes(x=Estimator, 
                 y=ISE, 
                 fill=Estimator)) + 
  geom_boxplot() +
  labs(y = "ISE", 
       title = "Fig.4.2 - Scenario 1, N=500"
       ) +
  theme(plot.title = element_text(size = 20, hjust = 0.5),
        axis.text.x = element_text(size = 15),
        axis.text.y = element_text(size = 15),
        axis.title.x=element_blank(),
        axis.title.y = element_text(size = 20),
        legend.position = "none",
        plot.margin = unit(c(0,0,0,0),"cm"))
```

![](Main_files/figure-gfm/S1N2-1.png)<!-- -->

Scenario 1, N=1000

``` r
set.seed(1)
x13 <- rgamma(N3,5,1)

k13 <- k_1

ise_knn13_full <- numeric(1000)
ise_kde13_full <- numeric(1000)

for(i in 1:1000){
  x13 <- rgamma(N3,5,1)
  
  knn13 <- knn.dist(x13,k13)
  dknn13 <- k13/(2*1000*knn13[,k13])
  
  bw13 <- bw.ucv.mod(x13)
  kde13 <- density(x13, bw=bw13)
  dkde13 <- kde13$y
  
  se_knn13 <- splinefun(x13, (dknn13-dgamma(x13,5,1))^2)
  ise_knn13 <- integrate(se_knn13, min(x13), max(x13), subdivisions=2000)$value
  ise_knn13_full[i] <- ise_knn13
  
  se_kde13 <- splinefun(kde13$x, (dkde13-dgamma(kde13$x,5,1))^2)
  ise_kde13 <- integrate(se_kde13, min(x13), max(x13))$value
  ise_kde13_full[i] <- ise_kde13
}

knn13df <- data.frame('ISE'=ise_knn13_full)
kde13df <- data.frame('ISE'=ise_kde13_full)
knn13df$Estimator <- 'KNDE'
kde13df$Estimator <- 'KDE'
df13 <- rbind(knn13df,kde13df)

ggplot(df13, aes(x=Estimator, 
                 y=ISE, 
                 fill=Estimator)) + 
  geom_boxplot() +
  labs(y = "ISE", 
       title = "Fig.4.3 - Scenario 1, N=1000"
       ) +
  theme(plot.title = element_text(size = 20, hjust = 0.5),
        axis.text.x = element_text(size = 15),
        axis.text.y = element_text(size = 15),
        axis.title.x=element_blank(),
        axis.title.y = element_text(size = 20),
        legend.position = "none",
        plot.margin = unit(c(0,0,0,0),"cm"))
```

![](Main_files/figure-gfm/S1N3-1.png)<!-- -->

Scenario 2, N=250

``` r
set.seed(1)
x21 <- rnorm(N1,0,0.1)

k21full <- numeric(10)
for(j in 1:10){
  x <- rnorm(250,5,1)
  ise <- numeric(116)
  for(i in 10:125){
    knn <- knn.dist(x,i)
    fknn <- i/(2*250*knn[,i])
    fse <- splinefun(x, (fknn-dnorm(x,1,0.1))^2)
    ise[i-9] <- integrate(fse, min(x), max(x), subdivisions=2000)$value
  }
  k21full[j] <- which.min(ise) + 9
}
k21 <- round(mean(k21full))

ise_knn21_full <- numeric(1000)
ise_kde21_full <- numeric(1000)

for(i in 1:1000){
  x21 <- rnorm(N1,0,0.1)
  
  knn21 <- knn.dist(x21,k21)
  dknn21 <- k21/(2*250*knn21[,k21])
  
  bw21 <- bw.ucv.mod(x21)
  kde21 <- density(x21, bw=bw21)
  dkde21 <- kde21$y
  
  se_knn21 <- splinefun(x21, (dknn21-dnorm(x21,0,0.1))^2)
  ise_knn21 <- integrate(se_knn21, min(x21), max(x21), subdivisions=2000)$value
  ise_knn21_full[i] <- ise_knn21
  
  se_kde21 <- splinefun(kde21$x, (dkde21-dnorm(kde21$x,0,0.1))^2)
  ise_kde21 <- integrate(se_kde21, min(x21), max(x21))$value
  ise_kde21_full[i] <- ise_kde21
}

knn21df <- data.frame('ISE'=ise_knn21_full)
kde21df <- data.frame('ISE'=ise_kde21_full)
knn21df$Estimator <- 'KNDE'
kde21df$Estimator <- 'KDE'
df21 <- rbind(knn21df,kde21df)

ggplot(df21, aes(x=Estimator, 
                 y=ISE, 
                 fill=Estimator)) + 
  geom_boxplot() +
  labs(y = "ISE", 
       title = "Fig.5.1 - Scenario 2, N=250"
       ) +
  theme(plot.title = element_text(size = 20, hjust = 0.5),
        axis.text.x = element_text(size = 15),
        axis.text.y = element_text(size = 15),
        axis.title.x=element_blank(),
        axis.title.y = element_text(size = 20),
        legend.position = "none",
        plot.margin = unit(c(0,0,0,0),"cm"))
```

![](Main_files/figure-gfm/S2N1-1.png)<!-- -->

Scenario 2, N=500

``` r
set.seed(1)
x22 <- rnorm(N2,0,0.1)

k22full <- numeric(10)
for(j in 1:10){
  x <- rnorm(500,5,1)
  ise <- numeric(241)
  for(i in 10:250){
    knn <- knn.dist(x,i)
    fknn <- i/(2*500*knn[,i])
    fse <- splinefun(x, (fknn-dnorm(x,1,0.1))^2)
    ise[i-9] <- integrate(fse, min(x), max(x), subdivisions=2000)$value
  }
  k22full[j] <- which.min(ise) + 9
}
k22 <- round(mean(k22full))

ise_knn22_full <- numeric(1000)
ise_kde22_full <- numeric(1000)

for(i in 1:1000){
  x22 <- rnorm(N2,0,0.1)
  
  knn22 <- knn.dist(x22,k22)
  dknn22 <- k22/(2*500*knn22[,k22])
  
  bw22 <- bw.ucv.mod(x22)
  kde22 <- density(x22, bw=bw22)
  dkde22 <- kde22$y
  
  se_knn22 <- splinefun(x22, (dknn22-dnorm(x22,0,0.1))^2)
  ise_knn22 <- integrate(se_knn22, min(x22), max(x22), subdivisions=2000)$value
  ise_knn22_full[i] <- ise_knn22
  
  se_kde22 <- splinefun(kde22$x, (dkde22-dnorm(kde22$x,0,0.1))^2)
  ise_kde22 <- integrate(se_kde22, min(x22), max(x22))$value
  ise_kde22_full[i] <- ise_kde22
}

knn22df <- data.frame('ISE'=ise_knn22_full)
kde22df <- data.frame('ISE'=ise_kde22_full)
knn22df$Estimator <- 'KNDE'
kde22df$Estimator <- 'KDE'
df22 <- rbind(knn22df,kde22df)

ggplot(df11, aes(x=Estimator, 
                 y=ISE, 
                 fill=Estimator)) + 
  geom_boxplot() +
  labs(y = "ISE", 
       title = "Fig.5.2 - Scenario 2, N=500"
       ) +
  theme(plot.title = element_text(size = 20, hjust = 0.5),
        axis.text.x = element_text(size = 15),
        axis.text.y = element_text(size = 15),
        axis.title.x=element_blank(),
        axis.title.y = element_text(size = 20),
        legend.position = "none",
        plot.margin = unit(c(0,0,0,0),"cm"))
```

![](Main_files/figure-gfm/S2N2-1.png)<!-- -->

Scenario 2, N=1000

``` r
set.seed(1)
x23 <- rnorm(N3,0,0.1)

k23 <- k_2

ise_knn23_full <- numeric(1000)
ise_kde23_full <- numeric(1000)

for(i in 1:1000){
  x23 <- rnorm(N3,0,0.1)
  
  knn23 <- knn.dist(x23,k23)
  dknn23 <- k23/(2*1000*knn23[,k23])
  
  bw23 <- bw.ucv.mod(x23)
  kde23 <- density(x23, bw=bw23)
  dkde23 <- kde23$y
  
  se_knn23 <- splinefun(x23, (dknn23-dnorm(x23,0,0.1))^2)
  ise_knn23 <- integrate(se_knn23, min(x23), max(x23), subdivisions=2000)$value
  ise_knn23_full[i] <- ise_knn23
  
  se_kde23 <- splinefun(kde23$x, (dkde23-dnorm(kde23$x,0,0.1))^2)
  ise_kde23 <- integrate(se_kde23, min(x23), max(x23))$value
  ise_kde23_full[i] <- ise_kde23
}

knn23df <- data.frame('ISE'=ise_knn23_full)
kde23df <- data.frame('ISE'=ise_kde23_full)
knn23df$Estimator <- 'KNDE'
kde23df$Estimator <- 'KDE'
df23 <- rbind(knn23df,kde23df)

ggplot(df23, aes(x=Estimator, 
                 y=ISE, 
                 fill=Estimator)) + 
  geom_boxplot() +
  labs(y = "ISE", 
       title = "Fig.5.3 - Scenario 2, N=1000"
       ) +
  theme(plot.title = element_text(size = 20, hjust = 0.5),
        axis.text.x = element_text(size = 15),
        axis.text.y = element_text(size = 15),
        axis.title.x=element_blank(),
        axis.title.y = element_text(size = 20),
        legend.position = "none",
        plot.margin = unit(c(0,0,0,0),"cm"))
```

![](Main_files/figure-gfm/S2N3-1.png)<!-- -->

Scenario 3, N=250

``` r
set.seed(1)
x31 <- numeric(N1)
for(j in seq_len(N1)) {
  z <- rbinom(1,1,0.5)
  if(z == 0) x31[j] <- rnorm(1,-1,1)
  else x31[j] <- rnorm(1,2,1)
}

k31full <- numeric(10)
for(j in 1:10){
  x <- numeric(250)
  for(k in seq_len(250)) {
    z <- rbinom(1,1,0.5)
    if(z == 0) x[k] <- rnorm(1,-1,1)
    else x[k] <- rnorm(1,2,1)
  }
  ise <- numeric(116)
  for(i in 10:125){
    knn <- knn.dist(x,i)
    fknn <- i/(2*250*knn[,i])
    fse <- splinefun(x, (fknn-mixed(x))^2)
    ise[i-9] <- integrate(fse, min(x), max(x), subdivisions=2000)$value
  }
  k31full[j] <- which.min(ise) + 9
}
k31 <- round(mean(k31full))

ise_knn31_full <- numeric(1000)
ise_kde31_full <- numeric(1000)

for(i in 1:1000){
  x31 <- numeric(N1)
  for(j in seq_len(N1)) {
    z <- rbinom(1,1,0.5)
    if(z == 0) x31[j] <- rnorm(1,-1,1)
    else x31[j] <- rnorm(1,2,1)
  }
  
  knn31 <- knn.dist(x31,k31)
  dknn31 <- k31/(2*250*knn31[,k31])
  
  bw31 <- bw.ucv.mod(x31)
  kde31 <- density(x31, bw=bw31)
  dkde31 <- kde31$y
  
  se_knn31 <- splinefun(x31, (dknn31-mixed(x31))^2)
  ise_knn31 <- integrate(se_knn31, min(x31), max(x31), subdivisions=2000)$value
  ise_knn31_full[i] <- ise_knn31
  
  se_kde31 <- splinefun(kde31$x, (dkde31-mixed(kde31$x))^2)
  ise_kde31 <- integrate(se_kde31, min(x31), max(x31))$value
  ise_kde31_full[i] <- ise_kde31
}

knn31df <- data.frame('ISE'=ise_knn31_full)
kde31df <- data.frame('ISE'=ise_kde31_full)
knn31df$Estimator <- 'KNDE'
kde31df$Estimator <- 'KDE'
df31 <- rbind(knn31df,kde31df)

ggplot(df31, aes(x=Estimator, 
                 y=ISE, 
                 fill=Estimator)) + 
  geom_boxplot() +
  labs(y = "ISE", 
       title = "Fig.6.1 - Scenario 3, N=250"
       ) +
  theme(plot.title = element_text(size = 20, hjust = 0.5),
        axis.text.x = element_text(size = 15),
        axis.text.y = element_text(size = 15),
        axis.title.x=element_blank(),
        axis.title.y = element_text(size = 20),
        legend.position = "none",
        plot.margin = unit(c(0,0,0,0),"cm"))
```

![](Main_files/figure-gfm/S3N1-1.png)<!-- -->

Scenario 3, N=500

``` r
set.seed(1)
x32 <- numeric(N2)
for(j in seq_len(N2)) {
  z <- rbinom(1,1,0.5)
  if(z == 0) x32[j] <- rnorm(1,-1,1)
  else x32[j] <- rnorm(1,2,1)
}

k32full <- numeric(10)
for(j in 1:10){
  x <- numeric(500)
  for(k in seq_len(500)) {
    z <- rbinom(1,1,0.5)
    if(z == 0) x[k] <- rnorm(1,-1,1)
    else x[k] <- rnorm(1,2,1)
  }
  ise <- numeric(241)
  for(i in 10:250){
    knn <- knn.dist(x,i)
    fknn <- i/(2*500*knn[,i])
    fse <- splinefun(x, (fknn-mixed(x))^2)
    ise[i-9] <- integrate(fse, min(x), max(x), subdivisions=2000)$value
  }
  k32full[j] <- which.min(ise) + 9
}
k32 <- round(mean(k32full))

ise_knn32_full <- numeric(1000)
ise_kde32_full <- numeric(1000)

for(i in 1:1000){
  x32 <- numeric(N2)
  for(j in seq_len(N2)) {
    z <- rbinom(1,1,0.5)
    if(z == 0) x32[j] <- rnorm(1,-1,1)
    else x32[j] <- rnorm(1,2,1)
  }
  
  knn32 <- knn.dist(x32,k32)
  dknn32 <- k32/(2*500*knn32[,k32])
  
  bw32 <- bw.ucv.mod(x32)
  kde32 <- density(x32, bw=bw32)
  dkde32 <- kde32$y
  
  se_knn32 <- splinefun(x32, (dknn32-mixed(x32))^2)
  ise_knn32 <- integrate(se_knn32, min(x32), max(x32), subdivisions=2000)$value
  ise_knn32_full[i] <- ise_knn32
  
  se_kde32 <- splinefun(kde32$x, (dkde32-mixed(kde32$x))^2)
  ise_kde32 <- integrate(se_kde32, min(x32), max(x32))$value
  ise_kde32_full[i] <- ise_kde32
}

knn32df <- data.frame('ISE'=ise_knn32_full)
kde32df <- data.frame('ISE'=ise_kde32_full)
knn32df$Estimator <- 'KNDE'
kde32df$Estimator <- 'KDE'
df32 <- rbind(knn32df,kde32df)

ggplot(df32, aes(x=Estimator, 
                 y=ISE, 
                 fill=Estimator)) + 
  geom_boxplot() +
  labs(y = "ISE", 
       title = "Fig.6.2 - Scenario 3, N=500"
       ) +
  theme(plot.title = element_text(size = 20, hjust = 0.5),
        axis.text.x = element_text(size = 15),
        axis.text.y = element_text(size = 15),
        axis.title.x=element_blank(),
        axis.title.y = element_text(size = 20),
        legend.position = "none",
        plot.margin = unit(c(0,0,0,0),"cm"))
```

![](Main_files/figure-gfm/S3N2-1.png)<!-- -->

Scenario 3, N=1000

``` r
set.seed(1)
x33 <- numeric(N3)
for(j in seq_len(N3)) {
  z <- rbinom(1,1,0.5)
  if(z == 0) x33[j] <- rnorm(1,-1,1)
  else x33[j] <- rnorm(1,2,1)
}

k33 <- k_3

ise_knn33_full <- numeric(1000)
ise_kde33_full <- numeric(1000)

for(i in 1:1000){
  x33 <- numeric(N3)
  for(j in seq_len(N3)) {
    z <- rbinom(1,1,0.5)
    if(z == 0) x33[j] <- rnorm(1,-1,1)
    else x33[j] <- rnorm(1,2,1)
  }
  
  knn33 <- knn.dist(x33,k33)
  dknn33 <- k33/(2*1000*knn33[,k33])
  
  bw33 <- bw.ucv.mod(x33)
  kde33 <- density(x33, bw=bw33)
  dkde33 <- kde33$y
  
  se_knn33 <- splinefun(x33, (dknn33-mixed(x33))^2)
  ise_knn33 <- integrate(se_knn33, min(x33), max(x33), subdivisions=2000)$value
  ise_knn33_full[i] <- ise_knn33
  
  se_kde33 <- splinefun(kde33$x, (dkde33-mixed(kde33$x))^2)
  ise_kde33 <- integrate(se_kde33, min(x33), max(x33))$value
  ise_kde33_full[i] <- ise_kde33
}

knn33df <- data.frame('ISE'=ise_knn33_full)
kde33df <- data.frame('ISE'=ise_kde33_full)
knn33df$Estimator <- 'KNDE'
kde33df$Estimator <- 'KDE'
df33 <- rbind(knn33df,kde33df)

ggplot(df33, aes(x=Estimator, 
                 y=ISE, 
                 fill=Estimator)) + 
  geom_boxplot() +
  labs(y = "ISE", 
       title = "Fig.6.3 - Scenario 3, N=1000"
       ) +
  theme(plot.title = element_text(size = 20, hjust = 0.5),
        axis.text.x = element_text(size = 15),
        axis.text.y = element_text(size = 15),
        axis.title.x=element_blank(),
        axis.title.y = element_text(size = 20),
        legend.position = "none",
        plot.margin = unit(c(0,0,0,0),"cm"))
```

![](Main_files/figure-gfm/S3N3-1.png)<!-- -->
