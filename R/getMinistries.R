#' Data on Ministries and Governing Parties since 1901
#' @return a tibble with one row per ministry and governing party. Ministries
#'   for which the Handbook lists no party (e.g. the first Barton Ministry) are
#'   kept, with `Party` and `pID` set to NA.
#' @export
#'
#' @examples
#' \donttest{
#' getMinistries()
#' }
getMinistries<-function(){
  raw<-fetch_handbook("StatisticalInformation/Ministries")
  if(is.null(raw)) return(NULL)

  dat<-lapply(raw, function(m){
    parties<-m$Parties
    if(length(parties)==0) parties<-list(list(Name=NA_character_, Id=NA_real_))
    dplyr::tibble(MinistryNumber=m$Id,
                  MinistryName=m$MinistryName,
                  DateStart=parse_handbook_date(m$DateStart),
                  DateEnd=parse_handbook_date(if(is.null(m$DateEnd)) NA else m$DateEnd),
                  Party=vapply(parties, function(p) p$Name, character(1)),
                  pID=vapply(parties, function(p) as.numeric(p$Id), numeric(1)))
  })
  dplyr::bind_rows(dat)
}
