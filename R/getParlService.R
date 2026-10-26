#' Data on parliamentary tenures of MPs and senators since 1901
#'
#' Returns a stored copy of the Handbook's parliamentary service records. The
#' date of the copy is in the `scraped` attribute of the result.
#'
#' @param chamber choose to include MPs ("house"), senators ("senate") or both ("all").
#' @param apply_errata if TRUE, replace values listed in [getErrata()] with
#'   their corrected values. By default the Handbook's values are returned.
#'
#' @return a tibble. `handbook_flag` marks rows with a known problem in the
#'   Handbook: `overlapping_term` (the term starts before the member's
#'   previous term ends), `placeholder_end_date` (the Handbook has 1900-01-01,
#'   returned as NA) and any issue listed in [getErrata()].
#' @export
#'
#' @examples getParlService(chamber="house")
getParlService<- function(chamber=c('all', 'house', 'senate'), apply_errata=FALSE){
  chamber<-match.arg(chamber)
  PHID <- DisplayName <- MemberOrSenator <- Electorate <-
    DateStart <- DateEnd <- Description <- handbook_flag <- NULL

  data <- load_extdata("tenures_raw.Rdata")
  scraped <- attr(data, "scraped")

  keys<-paste(data$PHID, substr(data$DateStart,1,10), substr(data$DateEnd,1,10), sep="|")
  placeholder<-is_placeholder_date(data$DateEnd)

  data$DateStart<-parse_handbook_date(data$DateStart)
  data$DateEnd<-parse_handbook_date(data$DateEnd)
  data$handbook_flag<-NA_character_
  data$handbook_flag<-add_flag(data$handbook_flag, placeholder, "placeholder_end_date")

  data<-apply_errata_table(data, "parl_service", keys, apply_errata)

  # a term that starts before the same person's previous term has ended
  data<-data|>dplyr::arrange(PHID, DateStart)
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
