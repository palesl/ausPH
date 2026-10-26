#' Data on electorates since 1901
#'
#' @return a tibble
#' @export
#'
#' @examples
#' \donttest{
#' getElectorates()
#' }
getElectorates<-function(){
  raw<-fetch_handbook("electorates")
  if(is.null(raw)) return(NULL)
  dat<-records_to_tibble(raw[["value"]])
  dat$Established<-parse_handbook_date(dat$Established)
  dat$Ceased<-parse_handbook_date(dat$Ceased)
  dat
}
