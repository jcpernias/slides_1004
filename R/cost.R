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

## b) Fit a quadratic CMe curve with a given value of CMe at Q, a given slope at that point
##    and a given width W at that ordinate.
fit2 <- function (Q, CMe, tg, W) {
  if (tg > 0)
    W <- -W
  a3 <- -tg/W
  a2 <- tg*(1 + 2 * Q/W)
  a1 <- CMe - a2 * Q - a3 * Q^2
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


## Points of the CMe curve for parameters par.
CMe <- function (par, Q = NULL, domain = NULL, nsamples = 128) {
  quad (par, X = Q, domain = domain, nsample = nsamples)
}

dCMe <- function (par, Q = NULL, domain = NULL, nsamples = 128) {
  quad (c(par[2], 2 * par[3], 0), X = Q, domain = domain, nsample = nsamples)
}

CMg.pars <- function (par) {
  c(par[1], 2 * par[2], 3 * par[3])
}

## Points of the CMg curve for parameters par.
CMg <- function (par, Q = NULL, domain = NULL, nsamples = 128) {
  quad (CMg.pars (par), X = Q, domain = domain, nsample = nsamples)
}

## Intersection of two CMe curves
intersect <- function (p1, p2) {
  roots <- polyroot(p1 - p2)
  x <- Re(roots[which(abs(Im(roots)) < sqrt(.Machine$double.eps))])
  if (length (x) == 2) {
    x <- x[which.min(CMe(p1, x)[, 2])]    
  }
  x
}

qsolve <- function (p, y, trim = NULL) {
  roots <- polyroot(p - c(y, 0, 0))
  x <- Re(roots[which(abs(Im(roots)) < sqrt(.Machine$double.eps))])
  if (!is.null (trim))
    x <- c(max(x[1], trim[1]), min(x[2], trim[2]))
  x
}

srpar <- function (x, w) {
  C <- CMe(parL, x)
  d <- dCMe(parL, x)
  fit2(Q = C[1], CMe = C[2], tg = d[2], W = w)  
}


plotFrml <- function (p) {
  signs <- ifelse (p < 0, "-", "+")
  if (signs[1] == "+")
    signs[1] = ""
  x <- c("", "*\\x", "*\\x^2")
  paste (signs, signif(abs(p)), x, sep = "", collapse = "")
}
  
plotCMe <- function (p, domain) {
  frml <- plotFrml (p)
  plot <- paste ("plot[domain=", signif(domain[1]), ":",
                 signif(domain[2]), "] ",
                 "(\\x,", frml, ")", sep = "")
  cat(plot)
}

plotCMg <- function (p, domain) {
    plotCMe(CMg.pars(p), domain)
}

plotCoord <- function (x, y = NULL) {
    pts <- paste (coord (x, y), collapse="\n")
    cat ("plot[smooth] coordinates {",
         pts,
         "}")
}

##  ----------------------------------------------------
##  Figures
##  ----------------------------------------------------

Qtop <- 80
nsamples <- 128

Q0 <- 50
CMe0 <- 80
CMg0 <- 50


## Long run curves
parL <- fit (Q = Q0, CMe = CMe0, CMg = CMg0)

domCMeL <- qsolve (parL, 150, trim = c(0, Qtop))
CMeL <- CMe (parL, domain=domCMeL)
dCMeL <- dCMe (parL, domain=domCMeL)

domCMgL <- qsolve (CMg.pars(parL),  185, trim = c(25, Qtop))
CMgL <- CMg (parL, domain=domCMgL)


## plotCMe(par15, dom15)

## plot (CMeL, type = "l", ylim=c(0, 200))
## lines (CMgL, col = "blue")

## Dicrete choice among two plant sizes
par30 <- srpar(30, 14)
dom30 <- qsolve(par30, 160, trim=c(0, 52))

par60 <- srpar(60,  9)
dom60 <- qsolve(par60, 160, trim=c(33, Qtop))

## lines (CMe (par30, domain=dom30), col="orange")
## lines (CMe (par60, domain=dom60), col="orange")

Q3060 <- intersect (par30, par60)
domL30a <- c(dom30[1], Q3060)
domL60a <- c(Q3060, dom60[2])
## lines (CMe (par30, domain=domL30), col="brown", lwd = 3)
## lines (CMe (par60, domain=domL60), col="brown", lwd = 3)

domg30 <- qsolve(CMg.pars(par30), 195, trim=c(25, Qtop))
domg60 <- qsolve(CMg.pars(par60), 195, trim=c(41, Qtop))
## lines (CMg (par30, domain=domg30), col="green")
## lines (CMg (par60, domain=domg60), col="green")

domgL30a <- c(domg30[1], Q3060)
domgL60a <- c(Q3060, domg60[2])

## lines (CMg (par30, domain=domgL30), col="green", lwd = 3)
## lines (CMg (par60, domain=domgL60), col="green", lwd = 3)

## points(rbind(CMe(par30, Q3060), CMe(par30, 30), CMg(par30, 30), CMe(par60, 60), CMg(par60, 60)))
Ql <- 35
## points(rbind(CMe(par30, Ql), CMe(par60, Ql)))

Qh <- 50
## points(rbind(CMe(par30, Qh), CMe(par60, Qh)))

## abline(v=Q3060)
## abline(v=Ql)
## abline(v=Qh)

## Short run curves at the long run efficient scale
par50 <- c(0, 0, 0)
par50[3] <- parL[3] * 3
par50[2] <- -2 * par50[3] * Q0
par50[1] <- CMe0 - (par50[2] + par50[3] * Q0) * Q0


dom50 <- qsolve(par50, 160, trim=c(0, Qtop))
## lines (CMe(par50, domain=dom50), col = "red")

domg50 <- c(45, 58.5)
## lines (CMg(par50, domain=domg50), col = "magenta")


## Short run curves 
par15 <- srpar(15, 16)
dom15 <- qsolve(par15, 160, trim=c(0, 28))

par40 <- srpar(40, 7)
dom40 <- qsolve(par40, 160, trim=c(0, 60))

par70 <- srpar(70, 16)
dom70 <- qsolve(par70, 160, trim=c(46, Qtop))

## lines (CMe (par15, domain=dom15), col="orange")
## lines (CMe (par40, domain=dom40), col="orange")
## lines (CMe (par70, domain=dom70), col="orange")


Q1530 <- intersect (par15, par30)
Q3040 <- intersect (par30, par40)
Q4050 <- intersect (par40, par50)
Q5060 <- intersect (par50, par60)
Q6070 <- intersect (par60, par70)
domL15 <- c(dom15[1], Q1530)
domL30 <- c(Q1530, Q3040)
domL40 <- c(Q3040, Q4050)
domL50 <- c(Q4050, Q5060)
domL60 <- c(Q5060, Q6070)
domL70 <- c(Q6070, dom70[2])

## lines (CMe (par15, domain=domL15), col="orange", lwd = 3)
## lines (CMe (par30, domain=domL30), col="orange", lwd = 3)
## lines (CMe (par40, domain=domL40), col="orange", lwd = 3)
## lines (CMe (par50, domain=domL50), col="orange", lwd = 3)
## lines (CMe (par60, domain=domL60), col="orange", lwd = 3)
## lines (CMe (par70, domain=domL70), col="orange", lwd = 3)

domL <- c(0, 50)
CL <- CMe (parL, domain=domL)
CL[, 2] <- CL[,1] * CL[,2]/1000

domS <- c(12, 44)
CMe30 <- CMe (par30, domain=domS)

C30 <- CMe30
C30[, 2] <- CMe30[,1] * CMe30[,2]/1000 
# plot (CL, type = "l")
# lines(C30, col = "green")

