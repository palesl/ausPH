#' Data on elections since 1901
#'
#' @param chamber Select from c("all","house","senate")
#' @param byelections Choose to include house by-elections. If .byelections = TRUE,
#' then a list of elections with by-elections and their divisions is returned.
#'
#' @return a tibble
#' @export
#'
#' @examples
#' getElections(chamber="all")

getElections<-function(chamber=c("all","house","senate"), byelections=FALSE){

  print("All federal elections excluding elections for casual vacancies in the Senate")
  Division <- Reps <- Senate <- Byelection <- NULL
  datesfile<-system.file("extdata", "ElectionDates.xlsx", package = "ausPH")
  dat<- readxl::read_excel(datesfile)
  dat$DateElection<-as.Date(dat$DateElection)

  if(missing(chamber)){
    stop("chamber must be specified")
  }

  if(chamber=="all" && byelections==T){
    return(dat)
  }

  if(chamber=="all" && byelections==F){
    return(dat |> dplyr::filter(Byelection==F)|>
             dplyr::select(-Division))
  }

  if(chamber=='house' && byelections==T){
    return(dat |> dplyr::filter(Reps==T))
  }

  if(chamber=='house' && byelections==F){
    return(dat |> dplyr::filter(Reps==T, Byelection==F)|>
             dplyr::select(-Division))
  }

  if(chamber=='senate'){
    return(dat |> dplyr::filter(Senate==T)|>
             dplyr::select(-Division))
  }
}

