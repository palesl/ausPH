#' Get a list of elections in the Australian Parliament
#'
#' @param chamber select from c("all","house","senate")
#' @param byelections choose to include house by elections. if .byelections = TRUE,
#' then a list of elections with byelections and their divisions will be returned.
#'
#' @return a tibble
#' @export
#'
#' @examples
#' getElections(chamber="all")

getElections<-function(chamber=c("all","house","senate"), byelections=FALSE){
  url<- "https://handbookapi.aph.gov.au/api/Elections/Elections"
  dat<-rjson::fromJSON(file=url)|>dplyr::bind_rows()

  Division <- Reps <- Senate <- NULL

  if(missing(chamber)){
    stop("chamber must be specified")
  }

  if(chamber=="all" && byelections==T){
    return(dat)
  }

  if(chamber=="all" && byelections==F){
    return(dat |> dplyr::filter(is.na(Division))|>
             dplyr::select(-Division))
  }

  if(chamber=='house' && byelections==T){
    return(dat |> dplyr::filter(Reps==T))
  }

  if(chamber=='house' && byelections==F){
    return(dat |> dplyr::filter(Reps==T, is.na(Division))|>
             dplyr::select(-Division))
  }

  if(chamber=='senate'){
    return(dat |> dplyr::filter(Senate==T)|>
             dplyr::select(-Division))
  }
}

