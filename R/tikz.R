cm <- function (x) {
  paste (x, "cm", sep = "")
}

handleopts <- function (opts) {
  if(is.null (opts) || length(opts) == 0)
    return("")
  
  optname <- names (opts)
  paste ("[\n",
         paste ("  ", optname, ifelse (optname == "", "", " = "), opts, 
                sep = "", collapse = ",\n"),
         "\n]", sep = "")
}

begin.env <- function (name, opts = NULL) {
  optstr <- handleopts (opts)
  str <- paste ("\\begin{", name, "}", optstr, sep = "")  
  cat (str, "\n")
}

end.env <- function (name) {
  cat (paste ("\\end{", name, "}", sep = ""), "\n")
}

Coord <- function (x, y = NULL) {
  if (is.null (y)) {
    stopifnot (length (x) == 2)
    y <- x[2]
    x <- x[1]
  }
  paste("(", signif(x), ", ", signif(y), ")", sep = "")
}


Path <- function (x, y, join = "--") {
  paste (Coord (x, y), collapse = paste(" ", join, "\n", sep = ""))
}

Plot <- function (x, y) {
  paste ("plot coordinates {",
         paste (Coord (x, y), collapse = "\n"),
         "}", sep = "\n")
}

Node <- function (label = "", at = NULL, opts = NULL) {
  optstr <- handleopts (opts)
  atstr <- ""
  if (!is.null (at)) {
    atstr <- paste (" at ", Coord(at), " ", sep = "")
  }
  cat(paste ("\\node", optstr, atstr, " {", label, "};"), "\n")
}

Rect <- function (x0, x1, y0, y1) {
  paste (Coord(x0, y0), " rectangle ", Coord (x1, y1), sep = "")
}

Draw <- function (..., opts = NULL) {
  args <- list(...)
  optstr <- handleopts (opts)
  str <- do.call (paste, args)
  cat (paste ("\\draw", optstr, "\n", str, ";", sep = ""), "\n")
}

Fill <- function (..., opts = NULL) {
  args <- list(...)
  optstr <- handleopts (opts)
  str <- do.call (paste, args)
  cat (paste ("\\fill", optstr, "\n", str, ";", sep = ""), "\n")
}

Axis <- function (xlimits, ylimits, origin = c(0, 0),
                  xlabel = NULL, ylabel = NULL, 
                  opts = NULL) {
  ## xlimits, ylimits: if length == 1, the opposite 
  ## limit is taken from origin.
  if (length (xlimits) == 1)
    xlimits <- c(xlimits, origin[1]) 

  if (length (ylimits) == 1)
    ylimits <- c(ylimits, origin[2]) 
  
  ## range: ensure lenght 2 and proper order
  xlimits <- range(xlimits)
  ylimits <- range(ylimits)
  
  ## Check if axes contain the coordinate origin
  xzero <- prod(xlimits - origin[1])
  yzero <- prod(ylimits - origin[2])
  
  xarrow <- ifelse(xzero == 0,
                   ifelse (xlimits[1] == origin[1], "->", "<-"),
                   "<->")
  yarrow <- ifelse(yzero == 0,
                   ifelse (ylimits[1] == origin[2], "->", "<-"),
                   "<->")

  ## Output x axe
  Draw (Path(xlimits, origin[2]), opts = c(opts, list("axis", xarrow)))
  
  ## Output y axe
  Draw (Path(origin[1], ylimits), opts = c(opts, list("axis", yarrow)))
  
  
  if (!is.null (xlabel)) {
    Node (xlabel, at = c(xlimits[2], origin[2]), opts = list("below"))
  }  

  if (!is.null (ylabel)) {
    Node (ylabel, at = c(origin[1], ylimits[2]), opts = list("left"))
  }  
}


