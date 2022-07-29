#' Title
#'
#' @param string A character vector with one element.
#' @param pattern What pattern to split on.
#' @param n how many elements in the string character vector
#'
#' @return A character vector.
#' @export
#'
#' @examples
str_split_one <- function(string, pattern, n = Inf) {
  stopifnot(is.character(string), length(string) <= 1)
  if (length(string) == 1) {
    stringr::str_split(string = string, pattern = pattern, n = n)[[1]]
  } else {
    character()
  }
}
