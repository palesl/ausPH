#' Data on individuals and biographical information since 1901
#' @return a list
#' @export
#'
#' @examples getIndividuals()
getIndividuals<-function(){
  url<- "https://handbookapi.aph.gov.au/api/individuals?$orderby=FamilyName,GivenName&$skip=0&$count=false&$select=PHID,DisplayName,Gender,State,StateAbbrev,SenateState,Electorate,Party"
  dat<-rjson::fromJSON(file=url)[["value"]]|>dplyr::bind_rows()
  return(dat)
}


