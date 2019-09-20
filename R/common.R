## ========================================================
## Poly Bezier curves
## ========================================================
## ========================================================


library(bezier)

## Utility functions
## --------------------------------------



## Degrees to radians
d2r <- function (x) pi * x / 180

## Radians to degrees
r2d<- function (x) 180 * x / pi


## Compute control point at distance r from p with angle
## theta (in radians)
ctlpoint <- function (p, theta, r) {
  p + r * c(cos(theta), sin(theta))
}

## Find control points of a poly-Bezier curve
PBfit <- function(x, start, end, tgx, 
                          start.angle = -90, end.angle = 180,
                          strength = 0) {
  if (length (strength) == 1) {
    strength.left = strength.right = strength
  } else if (length (strength) == 2) {
    strength.left = strength[1]
    strength.right = strength[2]
  } else {
    stop ("Invalid strength argument")
  }
  
  a0 <- start
  d0 <- x
  
  z0 <- d2r(start.angle)
  sl0 <- c(cos(z0), sin(z0))
  zd <- pi + atan(tgx)
  sld <- c(cos(zd), sin(zd))
  
  B <- a0 - d0
  A <- cbind(-sl0, sld)
  X <- solve(A, B)
  a2 <- a0 + X[1] * sl0
  a1 <- 0.5 * (a0 + a2)
  a2 <- a2 + strength.left * (d0 - a2)
  
  b3 <- end
  z3 <- d2r(end.angle)
  sl3 <- c(cos(z3), sin(z3))
  B <- d0 - end
  A <- cbind(-sld, sl3)
  X <- solve(A, B)
  b1 <- d0 + X[1] * sld
  b2 <- 0.5 * (b1 + b3)
  b1 <- b1 + strength.right * (d0 - b1)
  rbind (a0, a1, a2, d0, b1, b2, b3)
}

## Plot a poly-Bezier curve
PBplot <- function (pts, n = 128, ...) {
  t <- seq (0, 1, length.out = n)
  lines (rbind(bezier(t, pts[1:4,]),
               bezier(t, pts[4:7,])), ...)
  
}

## Compute x-y coordinates of a poly-Bezier curve
## with control points pts at given values of t
PBpoint <- function (t, pts) {
  if (any(t < 0) | any (t > 1))
    stop ("Indices out of range")
  tleft <- which(t <= 0.5)
  tright <- which(t > 0.5)
  
  n <- length(t) 
  xy <- matrix(0, nr = n, nc =2)
  
  nleft <- length (tleft)
  A0 <- matrix(rep (pts[1, ], each = nleft), nr = nleft)
  A1 <- matrix(rep (pts[2, ], each = nleft), nr = nleft)
  A2 <- matrix(rep (pts[3, ], each = nleft), nr = nleft)
  A3 <- matrix(rep (pts[4, ], each = nleft), nr = nleft)
  
  tl <- t[tleft] * 2 
  xy[tleft, ] <- (1 - tl)^3 * A0 + 3 * (1 - tl)^2 * tl * A1 +
    3 * (1 - tl) * tl^2 * A2 + tl^3 * A3
  
  nright <- length (tright)
  A0 <- matrix(rep (pts[4, ], each = nright), nr = nright)
  A1 <- matrix(rep (pts[5, ], each = nright), nr = nright)
  A2 <- matrix(rep (pts[6, ], each = nright), nr = nright)
  A3 <- matrix(rep (pts[7, ], each = nright), nr = nright)
  
  tr <- (t[tright] - 0.5) * 2 
  xy[tright, ] <- (1 - tr)^3 * A0 + 3 * (1 - tr)^2 * tr * A1 +
    3 * (1 - tr) * tr^2 * A2 + tr^3 * A3
  
  xy
  
}


## Compute x-y slopes of a poly-Bezier curve
## with control points pts at given values of t
PBslope <- function (t, pts) {
  if (any(t < 0) | any (t > 1))
    stop ("Indices out of range")
  tleft <- which(t <= 0.5)
  tright <- which(t > 0.5)
  
  n <- length(t) 
  xy <- matrix(0, nr = n, nc =2)
  
  D <- diff (pts)
  
  nleft <- length (tleft)
  A0 <- matrix(rep (D[1, ], each = nleft), nr = nleft)
  A1 <- matrix(rep (D[2, ], each = nleft), nr = nleft)
  A2 <- matrix(rep (D[3, ], each = nleft), nr = nleft)
  
  tl <- t[tleft] * 2 
  xy[tleft, ] <- 3 * (1 - tl)^2 * A0 + 6 * (1 - tl) * tl * A1 + 3 * tl^2 * A2
  
  nright <- length (tright)
  A0 <- matrix(rep (D[4, ], each = nright), nr = nright)
  A1 <- matrix(rep (D[5, ], each = nright), nr = nright)
  A2 <- matrix(rep (D[6, ], each = nright), nr = nright)
  
  tr <- (t[tright] - 0.5) * 2 
  xy[tright, ] <- 3 * (1 - tl)^2 * A0 + 6 * (1 - tl) * tl * A1 + 3 * tl^2 * A2
  
  xy
  
}


## ==========================================================
## ==========================================================
## Functions producing TikZ commands
## ==========================================================
## ==========================================================


## -------------------------------------
## Low level functions
## -------------------------------------


## xy coodinates formatting
coord <- function (x, y = NULL) {
    if(!is.null (y)) {
        n <- length (x)
        stopifnot (length(y) == n)
        X <- cbind(x, y)
    } else if (is.matrix (x)) {
        n <- nrow(x)
        X <- x
    } else {
        n <- 1
        X <- t(as.matrix (x))
    }

    apply (X, 1, function (p) {
        p <- ifelse(abs(p) < 1e-06, 0, p)
        paste ("(", signif(p[1], 5),
               ", ", signif(p[2], 5),
               ")", sep = "")
    })
}


## options formatting
fmtopts <- function(...) {
   opts <- list(...)
   n <- length (opts)
   nm <- names(opts)
   mid <- rep("", n)
   mid[which (nm != "")] <- " = "
   paste ("[",
          paste(nm, mid, opts, sep = "", collapse=",\n"),
          "]", sep = "")
}


## -------------------------------------
## High level functions
## -------------------------------------

## Draw the plot axes 
Axis <- function(xmax, ymax, xlabel, ylabel,
                 xlabel.opts = "below",
                 ylabel.opts = "left") {
    cat("\\draw[axis]\n", coord(0, ymax), " node",
        fmtopts(ylabel.opts), " {", ylabel, "} |-\n",
        coord(xmax, 0), " node",
        fmtopts(xlabel.opts), " {", xlabel, "};\n",
        sep = "")
}

Coordinates <- function (...) {
    args <- list(...)
    label <- names(args)
    
    pts <- sapply (args, coord)    
    cat("\\path[shape=coordinate]\n",
        paste (pts, " coordinate (", label, ")",
               sep = "", collapse = "\n"),
        ";\n", sep = "")
}

PBpath <- function (pb) {

    paste (coord(pb[1,]),
           ".. controls ",
           coord(pb[2, ]),
           " and ",
           coord(pb[3, ]),
           " .. ",
           coord(pb[4, ]),
           ".. controls ",
           coord(pb[5, ]),
           " and ",
           coord(pb[6, ]),
           " .. ",
           coord(pb[7, ]),
           sep = "")
}
