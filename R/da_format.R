#' Format string to display data provided with the datalegreya font
#'
#'
#' @param .tbl Dataframe containing data to display.
#' @param x Name of x column of data.
#' @param y Name of y column of data.
#' @param text String that the data is mapped onto.
#' @param xlab Boolean. Whether to display x axis. Default to FALSE.
#' @param ylab Boolean. Whether to display y axis. Default to FALSE.
#'
#' @examples
#' data <- data.frame(year = seq(2008, 2018, 1), val = sin(seq(0, pi, length.out = 11)))
#' t <- "datalegreya"
#' da_format(data, year, val, t)
#'
#' @export

da_format <- function(.tbl, x, y, text, xlab = FALSE, ylab = FALSE) {
  x <- rlang::enquo(x)
  y <- rlang::enquo(y)

  d <- dplyr::select(.tbl, x = !!x, y = !!y)

  res <- d %>%
    dplyr::mutate(y = normalise_levels(y)) %>%
    dplyr::mutate(text = stringr::str_split(text, "")[[1]]) %>%
    dplyr::mutate(text = stringr::str_glue("{text}|{y}")) %>%
    dplyr::pull(text) %>%
    stringr::str_flatten()

  if(xlab) {
    xmin = make_five(min(d$x))
    xmax = make_five(max(d$x))
    res <- stringr::str_glue("{<<xmin>>}<<res>>{<<xmax>>}", .open = "<<", .close = ">>")
  }

  if(ylab) {
    ymin = make_five(min(d$y))
    ymax = make_five(max(d$y))
    res <- stringr::str_glue("{res}[{ymax}[{ymin}]")
  }

  res
}

normalise_levels <- function(y, min = 0, max = 3) {
  scale <- (y - min(y)) / (max(y) - min(y)) * 3
  round(scale, digits = 0)
}

make_five <- function(x) {
  l <- stringr::str_length(x)
  if (l == 5) return(x)
  if (l < 5) {
    s <- stringr::str_sub("     ", 1L, 5 - l)
    return(stringr::str_glue("{x}{s}"))
  }
  if (l > 5) stringr::str_sub(x, 1L, 5L)
}
