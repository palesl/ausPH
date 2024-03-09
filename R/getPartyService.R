#' data on party service of MPs and senators since 1901
#'
#' up to date as of 9th March 2024
#'
#' @return a tibble
#' @export
#'
#' @examples getPartyService()
getPartyService<- function(){

  data <- system.file("extdata", "partyService_raw.Rdata", package = "ausPH")

  load(data)

  # clean dates

  data$DateStart<-gsub("T00:00:00","", data$DateStart)
  data$DateEnd<-gsub("T00:00:00","", data$DateEnd)

  data$DateStart<-as.Date(data$DateStart)
  data$DateEnd<-as.Date(data$DateEnd)
  PHID <- DisplayName <-
    DateStart <- DateEnd<-NULL


  data<- data|>dplyr::select(PHID, DisplayName, DateStart,
                             DateEnd, Party, PartyColour)

  data<- data|>dplyr::as_tibble()
}
