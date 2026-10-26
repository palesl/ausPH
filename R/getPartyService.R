#' Data on party service of MPs and senators since 1901
#'
#' Returns a stored copy of the Handbook's party service records. The date of
#' the copy is in the `scraped` attribute of the result.
#'
#' @param apply_errata if TRUE, replace values listed in [getErrata()] with
#'   their corrected values. By default the Handbook's values are returned.
#'
#' @return a tibble. `handbook_flag` marks rows with a known problem in the
#'   Handbook: `same_day_party_record` (a one-day record that starts on the
#'   same day as another party record for the same person),
#'   `placeholder_end_date` (the Handbook has 1900-01-01, returned as NA) and
#'   any issue listed in [getErrata()].
#' @export
#'
#' @examples getPartyService()
getPartyService<- function(apply_errata=FALSE){
  PHID <- DisplayName <- DateStart <- DateEnd <- Party <- PartyColour <-
    handbook_flag <- NULL

  data <- load_extdata("partyService_raw.Rdata")
  scraped <- attr(data, "scraped")

  keys<-paste(data$PHID, substr(data$DateStart,1,10), data$Party, sep="|")
  placeholder<-is_placeholder_date(data$DateEnd)

  data$DateStart<-parse_handbook_date(data$DateStart)
  data$DateEnd<-parse_handbook_date(data$DateEnd)
  data$handbook_flag<-NA_character_
  data$handbook_flag<-add_flag(data$handbook_flag, placeholder, "placeholder_end_date")

  data<-apply_errata_table(data, "party_service", keys, apply_errata)

  # one-day records that start alongside another record for the same person
  starts<-paste(data$PHID, data$DateStart)
  same_day<-data$DateStart==data$DateEnd & duplicated(starts) | data$DateStart==data$DateEnd & duplicated(starts, fromLast=TRUE)
  data$handbook_flag<-add_flag(data$handbook_flag, same_day, "same_day_party_record")

  data<- data|>dplyr::select(PHID, DisplayName, DateStart,
                             DateEnd, Party, PartyColour, handbook_flag)|>
    dplyr::arrange(PHID, DateStart)|>
    dplyr::as_tibble()
  attr(data, "scraped")<-scraped
  data
}
