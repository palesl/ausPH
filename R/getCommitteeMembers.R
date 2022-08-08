#' Data on committee memberships since 1902
#'
#' @return a tibble
#' @export
#'
#' @examples getCommitteeMembers()
getCommitteeMembers<-function(){
  url<- "https://handbookapi.aph.gov.au/api/recordsofservice?$select=PHID,Value1,Value2,DateStart1,DateEnd1&$apply=filter(ROSTypeID%20eq%202)&$orderby=DateStart1,Value1,Value2"
  dat<-rjson::fromJSON(file=url)[["value"]]|>dplyr::bind_rows()
  committee_type<-committee_area<-phid<-start_date<-end_date<-NULL
  names(dat)[2]<-"committee_type"
  names(dat)[3]<-"committee_area"

  url<- "https://handbookapi.aph.gov.au/api/individuals?$orderby=FamilyName,GivenName&$skip=0&$count=false&$select=PHID,DisplayName"
  dat_name<-rjson::fromJSON(file=url)[["value"]]|>dplyr::bind_rows()

  dat<-dat|> dplyr::left_join(dat_name)
  DisplayName<-NULL
  names(dat)[1]<-"phid"
  names(dat)[4]<- 'start_date'
  names(dat)[5]<- 'end_date'
  dat<- dat|>dplyr::select(phid, DisplayName, committee_type,committee_area,start_date,end_date)

  return(dat)
}


