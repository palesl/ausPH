#' Get a list of individuals
#' @return a list
#' @export
#'
#' @examples getIndividuals()
getIndividuals<-function(){
  url<- "https://handbookapi.aph.gov.au/api/individuals?$orderby=FamilyName,GivenName&$skip=0&$count=false&$select=PHID,DisplayName,MPorSenator,Gender,State,StateAbbrev,SenateState,Electorate,Party,RepresentedParties,RepresentedStates,RepresentedElectorates"
  dat<-rjson::fromJSON(file=url)[["value"]]


  return(dat)

}
