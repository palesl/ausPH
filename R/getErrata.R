#' Known errors in the Parliamentary Handbook
#'
#' A table of values the package has found to be wrong in the Parliamentary
#' Handbook, with the corrected value and the evidence for it. By default the
#' get* functions return the Handbook's values and only mark these rows in
#' their `handbook_flag` column; with `apply_errata = TRUE` they replace the
#' value with `corrected_value`.
#'
#' An erratum applies only while the Handbook still has `handbook_value`, so
#' once the Handbook is fixed the erratum stops having any effect.
#'
#' @return a tibble with one row per correction: the table and row it applies
#' to (`table`, `key`), the `field`, the `handbook_value`, the
#' `corrected_value`, a short `issue` code, the `evidence` and its `source`.
#' @export
#'
#' @examples getErrata()
getErrata<-function(){
  file<-system.file("extdata", "errata.csv", package = "ausPH")
  readr::read_csv(file, col_types = readr::cols(.default = "c"))
}
