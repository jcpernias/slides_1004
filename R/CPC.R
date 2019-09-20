
## Curva precio consumo
#===============================================================
#===============================================================


## Axes
## --------------------------------------
maxX <- 65
maxY <- 50

## Ordinate of budget lines
Y0 <- 35

## CPC
CPC0 <- c(0, Y0)
CPC1 <- c(47, 26)
CPCx <- c(10, 15)

CPC <- PBfit(CPCx, CPC0, CPC1, 0, end.angle = 200) 

## Optimal bundles
opt <- PBpoint(c(0.5, 0.66, 0.75), CPC)




## Budget lines
## --------------------------------------

## slopes
sl0 <- (opt[1,2] - Y0)/opt[1, 1]
sl1 <- (opt[2,2] - Y0)/opt[2, 1]
sl2 <- (opt[3,2] - Y0)/opt[3, 1]

## abcissas
X0 <- opt[1, 1] - opt[1, 2] / sl0
X1 <- opt[2, 1] - opt[2, 2] / sl1
X2 <- opt[3, 1] - opt[3, 2] / sl2

## Indiference curves
I0 <- PBfit (opt[1, ], c(5, 37), c(25, 5), sl0, strength = 0.3)
I1 <- PBfit (opt[2, ], c(10, 37), c(30, 10), sl1, strength = 0.3)
I2 <- PBfit (opt[3, ], c(13, 37), c(34, 15), sl2, strength = 0.3)


## Demand curve

tidx <- seq(0.44, 1, length.out = 128)
cpc <- PBpoint(tidx, CPC)
Px <- apply(cpc, 1, function (x) -(x[2]-Y0)/x[1])
X <- cpc[, 1]



