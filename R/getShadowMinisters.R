#' Data on Shadow Ministers since 1901
#' @return a tibble
#' @export
#'
#' @examples getShadowMinisters()
getShadowMinisters<-function(){
  url<- "https://handbookapi.aph.gov.au/api/shadowministryrecords"
  dat<-rjson::fromJSON(file=url)[["value"]]|>dplyr::bind_rows()
  RDateStart<- RDateEnd<- MDateStart<- MDateEnd<-NULL
  dat$RDateStart<- as.Date(dat$RDateStart)
  dat$RDateEnd<- as.Date(dat$RDateEnd)
  dat$MDateStart<- gsub(" 12:00:00 AM","",dat$MDateStart)
  dat$MDateEnd<- gsub(" 12:00:00 AM","",dat$MDateEnd)
  dat$MDateStart<- as.Date(dat$MDateStart, format="%d/%m/%Y")
  dat$MDateEnd<- as.Date(dat$MDateEnd, format="%d/%m/%Y")

  return(dat)
}
