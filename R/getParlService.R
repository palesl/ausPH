#' data on parliamentary tenures of MPs and senators since 1901
#'
#' up to date as of 13th December 2022
#'
#' @param chamber choose to include MPs, senators or both.
#'
#' @return a tibble
#' @export
#'
#' @examples getParlService(chamber="house")
getParlService<- function(chamber=c('all', 'house', 'senate')){

  data <- system.file("extdata", "tenures_raw.Rdata", package = "ausPH")

  load(data)

  # clean dates

  data$DateStart<-gsub("T00:00:00","", data$DateStart)
  data$DateEnd<-gsub("T00:00:00","", data$DateEnd)

  data$DateStart<-as.Date(data$DateStart)
  data$DateEnd<-as.Date(data$DateEnd)
  PHID <- DisplayName <- Senate <-  senate <-MemberOrSenator <- Electorate <-
    DateStart <- DateEnd <-Description<-NULL


  data<- data|>dplyr::select(PHID, DisplayName,MemberOrSenator, Electorate, DateStart,
                      DateEnd, Description)

  data<- data|>dplyr::as_tibble()

  if(chamber=='all'){
    return(data)
  }

  if(chamber=='house'){
    data_house<-data|>dplyr::filter(MemberOrSenator=="Member")|>
      dplyr::select(-MemberOrSenator)
    return(data_house)
  }

  if(chamber=='senate'){
    data_senate<-data|>dplyr::filter(MemberOrSenator=="Senator")|>
      dplyr::select(-MemberOrSenator)
    return(data_senate)  }
}
