#' Get a list of electorates
#'
#' @return a tibble
#' @export
#'
#' @examples getElectorates()
getElectorates<-function(){
  url<- "https://handbookapi.aph.gov.au/api/electorates"
  dat<-rjson::fromJSON(file=url)[["value"]]|>dplyr::bind_rows()
  dat$Established<- as.Date(dat$Established)
  dat$Ceased<- as.Date(dat$Ceased)

  return(dat)

}
