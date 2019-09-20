library(bezier)


## Control points of three chained quadratic bezier curves
d0 <- c(0,5)
d1 <- c(20, 80)
d3 <- c(35, 110)
d2 <- (d1 + d3)/2 
d5 <- c(55, 5)
d4 <- (3 * d3 + d5)/4
d6 <- c(90, -10)

## Samples for pots
nsmpl <- 80
tidx <- seq(0, 1, length.out = nsmpl)

## Compute PMg curve
D1 <- bezier(tidx, rbind(d0, d1, d2))
D2 <- bezier(tidx, rbind(d2, d3, d4))
D3 <- bezier(tidx, rbind(d4, d5, d6))

N1 <- nsmpl - 1
D <- rbind(D1[1:N1,], D2[1:N1,], D3[1:nsmpl,])
PMg <- D[, 2]/100 
L <- D[, 1]

## Integrate PMg to obtain Q
dL <- c(0, diff(L))
Q <- cumsum(PMg * dL)

## Average product
PMe <- Q / L
PMe[1] <- PMg[1]


## Two points
tA <- 40
tB <- 180

## Maximum PMg
tC <- which.max(PMg)

## Maximum Q
N <- length(Q)


tD0  <- which.min(abs(PMg[tC:N])) + tC
PMg0 <- PMg[tD0]
tD1 <- tD0 + 1
PMg1 <- PMg[tD1]
if (PMg0 * PMg1 > 0) {
    tD1 <- tD0 - 1
    PMg1 <- PMg[tD1]
}
    

## Maximum PMe
gap <- PMg - PMe

tE0 <- which.min(abs(gap[tC:N])) + tC
gap0 <- gap[tE0]
tE1 <- tE0 + 1
gap1 <- gap[tE1]
if (gap0 * gap1 > 0) {
    tE1 <- tE0 - 1
    gap1 <- gap[tE1]
}
    

