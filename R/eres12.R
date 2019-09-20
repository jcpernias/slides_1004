
## Curva precio consumo
#===============================================================
#===============================================================


## Axes
## --------------------------------------
maxX <- 42
maxY <- 43

## Ordinate of budget lines
rp0.A <- c(0, 32)

## Abcissa of the original budget line
rp0.B <- c(40, 0)

## Slope of the original budget line
sl0 <- (rp0.A[2] - rp0.B[2])/(rp0.A[1] - rp0.B[1])

## Initial choice
X0 <- 12
E0 <- c(X0, rp0.A[2] + sl0 * X0)

## Initial indifference curve
I0 <- PBfit(E0, c(3, 42), c(35, 17), sl0, start.angle=-80)


## Find a point of I0 with abcissa approx. equal to a value 
tidx <- seq(0, 0.5, length.out = 128)
I0.pts <- PBpoint (tidx, I0)


## Intermediate point
tH <- which.min(abs(I0.pts[, 1] - 7))
dxdy <- PBslope (tidx[tH], I0)

EH <- I0.pts[tH, ]
sl1 <- dxdy[2]/dxdy[1]
XH <- EH[1]

## Intermediate budget line
rpH.A <- c(XH - EH[2] / sl1, 0)
rpH.B <- c(0, EH[2] - XH * sl1)

## Final budget abcissa
rp1.B <- c(-rp0.A[2] / sl1, 0)

X1 <- 15
E1 <- c(X1, rp0.A[2] + sl1 * X1)
I1 <- PBfit(E1, c(2, 40), c(27, 1.5), sl1, strength=0.3, start.angle=-85)






