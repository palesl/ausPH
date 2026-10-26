#' Data on committee memberships since 1902
#'
#' @return a tibble. `end_date` is NA for current memberships.
#' @export
#'
#' @examples
#' \donttest{
#' getCommitteeMembers()
#' }
getCommitteeMembers<-function(){
  PHID<-DisplayName<-Value1<-Value2<-DateStart1<-DateEnd1<-NULL
  raw<-fetch_handbook("recordsofservice?$select=PHID,Value1,Value2,DateStart1,DateEnd1&$apply=filter(ROSTypeID%20eq%202)&$orderby=DateStart1,Value1,Value2")
  raw_name<-fetch_handbook("individuals?$orderby=FamilyName,GivenName&$skip=0&$count=false&$select=PHID,DisplayName")
  if(is.null(raw) || is.null(raw_name)) return(NULL)
  dat<-records_to_tibble(raw[["value"]])
  dat_name<-records_to_tibble(raw_name[["value"]])

  dat|>dplyr::left_join(dat_name, by="PHID")|>
    dplyr::transmute(phid=PHID, DisplayName,
                     committee_type=Value1, committee_area=Value2,
                     start_date=parse_handbook_date(DateStart1),
                     end_date=parse_handbook_date(DateEnd1))
}
