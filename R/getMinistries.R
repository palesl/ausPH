#' Data on Ministries and Governing Parties since 1901
#' @return a tibble
#' @export
#'
#' @examples getMinistries()
getMinistries<-function(){
  url<- "https://handbookapi.aph.gov.au/api/StatisticalInformation/Ministries"
  dat<-rjson::fromJSON(file=url)|>dplyr::bind_rows()

  #clean dates

  dat$DateEnd<-gsub("T00:00:00","",dat$DateEnd)|>as.Date()
  dat$DateStart<-gsub("T00:00:00","",dat$DateStart)|>as.Date()

  # add parties

  dat$Party<-stringr::str_remove(dat$Parties,'.*Name = "')
  dat$Party<-stringr::str_remove(dat$Party,'\".*')

  dat<-dat|>dplyr::select(Id,MinistryName,DateStart,DateEnd,Party)

  names(dat)[1]<-'MinistryNumber'

  return(dat)
}
