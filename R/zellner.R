
GPF <- function (alpha, delta, theta, gamma) {
  stopifnot (alpha > 0, delta >= 0 && delta <= 1, theta >= 0, gamma > 0)
  logRHS <- function (L, K) {
    log(gamma) + alpha * delta * log (L) + 
      alpha * (1 - delta) * log (K)
  }
  
  logLHS <- function (q) {
    log(q) + theta * q
  }
  
  ## Production
  Q <- function (L, K){
    lrhs <- logRHS (L, K)
    rhs <- exp (lrhs)
    
    if (theta == 0.0)
      return (rhs)
    
    qmax <- rhs
    fqmax <- logLHS(qmax)
    qmin <- qmax / 2
    fqmin <- logLHS(qmin)
    while (fqmin > lrhs) {
      qmin <- qmin / 2
      fqmin <- logLHS (qmin)
    }        
    zero <- uniroot (function (x) logLHS(x) - lrhs, 
                     lower = qmin, upper = qmax,
                     f.lower = fqmin - lrhs, f.upper = fqmax - lrhs,
                     tol = .Machine$double.eps^0.5, maxiter = 1000)
    zero$root
  }
  
  PMeL <- function (L, K) {
    Q(L, K) / L
  }
  
  PMeK <- function (L, K) {
    Q(L, K) / K
  }
  
  PML <- function(L, K) {
    q <- Q(L, K)
    alpha * delta * q / ((1 + theta * q) * L)
  }
  
  PMK <- function(L, K) {
    q <- Q(L, K)
    alpha * (1 - delta) * q / ((1 + theta * q) * K)
  }
  
  Ld.sr <- function (q, w, r, K) {
    k <- 1 / (alpha * delta)
    num <- (q / gamma * exp (q * theta))^k
    den <- K^((1 - delta) / delta)
    num / den
  }
  
  CT.sr  <- function (q, w, r, K) {
    L <- Ld.sr (q, w, r, K)
    w * L + r * K
  }
  
  CV.sr  <- function (q, w, r, K) {
    w * Ld.sr (q, w, r, K)
  }
  
  CF.sr <- function (q, w, r, K) {
    rep_len (r * K, length(q))
  }
  
  CMe.sr <- function (q, w, r, K) {
    CT.sr (q, w, r, K) / q
  }
  
  CVMe.sr <- function (q, w, r, K) {
    CV.sr (q, w, r, K) / q
  }
  
  CFMe.sr <- function (q, w, r, K) {
    r * K / q
  }
  
  CMg.sr <- function (q, w, r, K) {
    CV <- CV.sr (q, w, r, K)
    (1 + theta * q) / (alpha * delta * q) * CV
  }

  Ld.lr <- function (q, w, r) {
    num <- q / gamma * exp (theta * q)
    den <- (1 - delta) * w / (delta * r)
    num^(1/alpha) / den^(1 - delta)
  }
  
  CT.lr <- function (q, w, r) {
    L <- Ld.lr (q, w, r)
    w * L / delta
  }
  
  CMe.lr <- function (q, w, r) {
    CT.lr (q, w, r) / q
  }
  
  CMg.lr <- function (q, w, r) {
    C <- CT.lr (q, w, r)
    (1 + theta * q) / (alpha * q) * C
  }

  list (alpha = alpha,
        delta = delta,
        theta = theta,
        gamma = gamma,
        logLHS = logLHS,
        logRHS = logRHS,
        Q = Q,
        PMeL = PMeL,
        PMeK = PMeK,
        PML = PML,
        PMK = PMK,
        Ld.sr = Ld.sr,
        CT.sr = CT.sr,
        CV.sr = CV.sr,
        CF.sr = CF.sr,
        CMe.sr = CMe.sr,
        CVMe.sr = CVMe.sr,
        CFMe.sr = CFMe.sr,
        CMg.sr = CMg.sr,
        Ld.lr = Ld.lr,
        CT.lr = CT.lr,
        CMe.lr = CMe.lr,
        CMg.lr = CMg.lr
        )
}


