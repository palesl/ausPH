#' Get list of Parliaments, their start date, dissolution date, end date and election date
#'
#' @return a tibble
#' @export
#'
#' @examples getParliaments()
getParliaments<-function(){
  ParliamentNext<-PartiesByParliament<- NULL
  url<- "https://handbookapi.aph.gov.au/api/parliaments"
  dat<-rjson::fromJSON(file=url)[["value"]]|>dplyr::bind_rows()|>
    dplyr::select(-ParliamentNext, -PartiesByParliament)|>
    dplyr::distinct()
  dat$DateElection<- as.Date(dat$DateElection)
  dat$DateOpening<- as.Date(dat$DateOpening)
  dat$DateDissolution<- as.Date(dat$DateDissolution)
  dat$ParliamentEnd<- as.Date(dat$ParliamentEnd)


  return(dat)

}
