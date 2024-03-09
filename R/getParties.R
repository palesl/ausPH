#' Data on parties since 1901
#' @return a tibble
#' @export
#'
#' @examples getParties()
getParties<-function(){
  url<- "https://handbookapi.aph.gov.au/api/parties"
  dat<-rjson::fromJSON(file=url)[["value"]]|>dplyr::bind_rows()
  return(dat)
}
