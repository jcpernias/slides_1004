
## Curva precio consumo
#===============================================================
#===============================================================


## Axes
## --------------------------------------
maxX <- 110
maxY <- 110

## Ordinate of budget lines
Y0 <- 45
Y1 <- 67.5
Y2 <- 90

## Budget lines slope
slope <- -1

## CRC: quadratic curve through (0, 0), E0, and
## a maximum when X = XM
X0 <- 15
E0 <- c(X0, Y0 + slope * X0)


XM <- 70
c <- E0[2] / (X0 * (X0 - 2 * XM))
b <- - 2 * XM * c

## Tangency points
X1 <- Re(polyroot (c(Y1, slope - b, -c))[1])
X2 <- Re(polyroot (c(Y2, slope - b, -c))[1])

E1 <- c(X1, Y1 + slope * X1)
E2 <- c(X2, Y2 + slope * X2)


## Indifference curves
I0 <- PBfit(E0, c(5, 92), c(92, 20), slope)
I1 <- PBfit(E1, c(13, 92), c(92, 28), slope)
I2 <- PBfit(E2, c(23, 92), c(92, 38), slope)
