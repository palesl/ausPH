#' Data on Parliamentary terms since 1901
#'
#' @return a tibble
#' @export
#'
#' @examples
#' \donttest{
#' getParliaments()
#' }
getParliaments<-function(){
  raw<-fetch_handbook("parliaments")
  if(is.null(raw)) return(NULL)
  dat<-records_to_tibble(raw[["value"]])|>
    dplyr::distinct()
  for(col in c("DateElection","DateOpening","DateDissolution","ParliamentEnd")){
    dat[[col]]<-parse_handbook_date(dat[[col]])
  }
  dat
}
