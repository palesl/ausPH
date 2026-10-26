#' Data on parliamentary tenures of MPs and senators since 1901
#'
#' By default the whole table is retrieved from the Handbook (one request).
#' If the Handbook cannot be reached, or `update = FALSE`, the copy stored in
#' the package is returned instead. The date the data was retrieved is in the
#' `scraped` attribute of the result.
#'
#' @param chamber choose to include MPs ("house"), senators ("senate") or both ("all").
#' @param apply_errata if TRUE, replace values listed in [getErrata()] with
#'   their corrected values. By default the Handbook's values are returned.
#' @param update if TRUE (the default), retrieve the current data from the
#'   Handbook; if FALSE, use the stored copy.
#'
#' @return a tibble. `DateEnd` is NA for terms that have not ended.
#'   `handbook_flag` marks rows with a known problem in the Handbook:
#'   `overlapping_term` (the term starts before the member's previous term
#'   ends), `placeholder_end_date` (a term that is not the member's latest has
#'   no end date in the Handbook) and any issue listed in [getErrata()].
#' @export
#'
#' @examples
#' \donttest{
#' getParlService(chamber="house")
#' }
#' # the copy stored in the package, without querying the Handbook
#' getParlService(chamber="house", update=FALSE)
getParlService<- function(chamber=c('all', 'house', 'senate'), apply_errata=FALSE, update=TRUE){
  chamber<-match.arg(chamber)
  PHID <- DisplayName <- MemberOrSenator <- Electorate <-
    DateStart <- DateEnd <- Description <- handbook_flag <- NULL

  data<-if(update) handbook_parl_service() else NULL
  if(is.null(data)){
    if(update) message("Returning the stored copy of the Handbook instead.")
    data<-load_extdata("tenures_raw.Rdata")
    scraped<-attr(data, "scraped")
  } else {
    scraped<-as.character(Sys.Date())
  }

  keys<-paste(data$PHID, substr(data$DateStart,1,10), substr(data$DateEnd,1,10), sep="|")
  placeholder<-is_placeholder_date(data$DateEnd)

  data$DateStart<-parse_handbook_date(data$DateStart)
  data$DateEnd<-parse_handbook_date(data$DateEnd)
  data$handbook_flag<-NA_character_

  data<-apply_errata_table(data, "parl_service", keys, apply_errata)

  data<-data|>dplyr::mutate(placeholder=placeholder)|>dplyr::arrange(PHID, DateStart)

  # an open end date is expected on the latest term, not on an earlier one
  latest<-!duplicated(data$PHID, fromLast=TRUE)
  data$handbook_flag<-add_flag(data$handbook_flag, data$placeholder & !latest, "placeholder_end_date")

  # a term that starts before the same person's previous term has ended
  prev_end<-dplyr::lag(data$DateEnd)
  same_person<-data$PHID==dplyr::lag(data$PHID)
  overlap<-same_person & !is.na(prev_end) & data$DateStart < prev_end
  data$handbook_flag<-add_flag(data$handbook_flag, overlap, "overlapping_term")

  data<- data|>dplyr::select(PHID, DisplayName, MemberOrSenator, Electorate, DateStart,
                      DateEnd, Description, handbook_flag)|>
    dplyr::as_tibble()

  if(chamber=='house'){
    data<-data|>dplyr::filter(MemberOrSenator=="Member")|>
      dplyr::select(-MemberOrSenator)
  }
  if(chamber=='senate'){
    data<-data|>dplyr::filter(MemberOrSenator=="Senator")|>
      dplyr::select(-MemberOrSenator)
  }
  attr(data, "scraped")<-scraped
  data
}
