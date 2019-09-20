##  ------------------------------------------------------
##  Utility functions
##  ------------------------------------------------------

## Quadratic fits:

## a) Fit a quadratic CMe curve with a given minimun value of CMe at Q and 
##    a given minimun value of CMg.
fit <- function (Q, CMe, CMg) {
  a2 <- -6 * (CMe - CMg) / Q
  a3 <- - a2 / (2 * Q)
  a1 <- CMe - a2 * Q / 2
  c(a1, a2, a3)
}

## Evaluates a quadratic function
quad <- function (par, X = NULL, domain = NULL, nsamples = 128) {
  if (is.null (X) && is.null(domain))
    stop ("Missing abcissas and domain")
  if (is.null (X))
    X <- seq (domain[1], domain[2], length.out = nsamples) 
  else if (!is.null (domain)) {
    X <- X[X >= domain[1] & X <= domain[2]]
  }
  Y <- par[1]  + X * (par[2] + X * par[3])
  cbind (X = X, Y = Y)    
}


CMg.pars <- function (par) {
  c(par[1], 2 * par[2], 3 * par[3])
}

plotCoord <- function (x, y = NULL) {
    pts <- paste (coord (x, y), collapse="\n")
    cat ("plot[smooth] coordinates {",
         pts,
         "}")
}

Q0 <- 50
CMe0 <- 3
CMg0 <- 1.5



parCVMe <- fit(Q0, CMe0, CMg0)
CVMe <- quad(parCVMe, domain=c(0, 80))
#plot (CVMe, type = "l", ylim=c(0, 10))
parCMg <- CMg.pars (parCVMe)
CMg <- quad(parCMg, domain=c(0, 80)) 
CMg <- CMg[which(CMg[, 2] <= 9.5), ]
#lines(CMg)

CV <- CVMe
CV[, 2] <- CVMe[, 2] * CVMe[, 1]

CF <- CV
CF[, 2] <- 50

CT <- CV
CT[, 2] <- CV[, 2] + CF[, 2]

CMe <- CT
CMe[, 2] <- CT[, 2] / CT[, 1]

CFMe <- CF
CFMe[, 2] <- CF[, 2] / CF[, 1]

CFMe <- CFMe[which(CFMe[, 2] <= 9.5), ]
CMe <- CMe[which(CMe[, 2] <= 9.5), ]

#lines(CFMe)
#lines(CMe)



#plot (CT, type = "l", ylim = c(0, 450))
#lines (CV)
#lines (CF)

Q <- CV[, c(2, 1)]


#plot (Q, type = "l", ylim = c(0, 80))

PMe <- Q
PMe[, 2] <- 1 / CVMe[ , 2]
#plot (PMe, type = "l", ylim = c(0, 0.7))

PMg <- Q
PMg[, 2] <- 1/quad(parCMg, domain=c(0, 80))[, 2]
#lines(PMg)

