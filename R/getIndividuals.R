#' Data on individuals and biographical information since 1901
#' @return a tibble
#' @export
#'
#' @examples
#' \donttest{
#' getIndividuals()
#' }
getIndividuals<-function(){
  raw<-fetch_handbook("individuals?$orderby=FamilyName,GivenName&$skip=0&$count=false&$select=PHID,DisplayName,Gender,DateOfBirth,State,StateAbbrev,SenateState,Electorate,Party")
  if(is.null(raw)) return(NULL)
  dat<-records_to_tibble(raw[["value"]])
  dat$DateOfBirth<-parse_handbook_date(dat$DateOfBirth)
  dat
}
