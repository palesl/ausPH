#' Data on parties since 1901
#' @return a tibble. Note that the Handbook gives a party a new `pID` when it
#'   changes its name, and that abbreviations are not unique (three parties
#'   use "LIB"), so `Abbrev` should not be used as a key.
#' @export
#'
#' @examples
#' \donttest{
#' getParties()
#' }
getParties<-function(){
  raw<-fetch_handbook("parties")
  if(is.null(raw)) return(NULL)
  dat<-records_to_tibble(raw[["value"]])
  # the Handbook pads many names and abbreviations with trailing spaces
  dplyr::mutate(dat, dplyr::across(dplyr::where(is.character), trimws))
}
