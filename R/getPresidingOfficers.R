#' Data on presiding officers and their deputies since 1901
#'
#' Speakers of the House of Representatives, Presidents of the Senate, their
#' deputies, Chairs of Committees, temporary chairs, members of the Speaker's
#' panel and acting holders of these offices, with the dates each person held
#' the office, from the Handbook's records of parliamentary positions.
#'
#' By default the whole table is retrieved from the Handbook (one request,
#' plus one for [getParlService()], used to place each office holder in a
#' chamber). If the Handbook cannot be reached, or `update = FALSE`, the copy
#' stored in the package is returned instead. The date the data was retrieved
#' is in the `scraped` attribute of the result.
#'
#' The Handbook records an office as held from one parliament to the next, so
#' a Speaker or President re-elected after a general election has one row per
#' parliament, with a gap between them.
#'
#' @param chamber choose to include House offices ("house"), Senate offices
#'   ("senate") or both ("all").
#' @param office the offices to include, as they are named in the Handbook's
#'   `Office` column (e.g. "Speaker of the House of Representatives",
#'   "President of the Senate"). The default, NULL, includes every office.
#' @param apply_errata if TRUE, replace values listed in [getErrata()] with
#'   their corrected values. By default the Handbook's values are returned.
#' @param update if TRUE (the default), retrieve the current data from the
#'   Handbook; if FALSE, use the stored copy.
#'
#' @return a tibble with one row per person and term in an office: `PHID`,
#'   `DisplayName`, `Office`, `Chamber` ("House" or "Senate"), `DateStart`,
#'   `DateEnd` (NA while the office is held), the Handbook's `Note` and
#'   `handbook_flag`. `Chamber` is the chamber the person sat in when the term
#'   began, since some office names (e.g. "Chairman of Committees") were used
#'   in both chambers. `handbook_flag` marks rows with a known problem in the
#'   Handbook: `placeholder_start_date` (no start date), `placeholder_end_date`
#'   (no end date, though the person has left parliament), `end_before_start`,
#'   `outside_parliamentary_service` (the term starts when the person was not
#'   in parliament, according to [getParlService()]) and any issue listed in
#'   [getErrata()].
#' @export
#'
#' @examples
#' # Speakers, from the copy stored in the package
#' getPresidingOfficers(chamber = "house",
#'                      office = "Speaker of the House of Representatives",
#'                      update = FALSE)
#' \donttest{
#' getPresidingOfficers()
#' }
getPresidingOfficers<-function(chamber=c("all", "house", "senate"), office=NULL,
                               apply_errata=FALSE, update=TRUE){
  chamber<-match.arg(chamber)
  PHID <- DisplayName <- Office <- Chamber <- DateStart <- DateEnd <- Note <-
    handbook_flag <- NULL

  data<-if(update) handbook_presiding_officers() else NULL
  if(is.null(data)){
    if(update) message("Returning the stored copy of the Handbook instead.")
    data<-load_extdata("presiding_officers.Rdata")
    scraped<-attr(data, "scraped")
    update<-FALSE
  } else {
    scraped<-as.character(Sys.Date())
  }

  keys<-paste(data$PHID, data$Office, substr(data$DateStart, 1, 10), sep="|")
  no_start<-is_placeholder_date(data$DateStart)
  data$DateStart<-parse_handbook_date(data$DateStart)
  data$DateEnd<-parse_handbook_date(data$DateEnd)
  data$handbook_flag<-NA_character_
  data<-apply_errata_table(data, "presiding_officers", keys, apply_errata)

  service<-suppressMessages(getParlService("all", update=update))
  data$Chamber<-officer_chamber(data, service)

  # rule-based flags
  left_parliament<-!data$PHID %in% service$PHID[is.na(service$DateEnd)]
  in_service<-officer_in_service(data, service)
  data$handbook_flag<-add_flag(data$handbook_flag, no_start, "placeholder_start_date")
  data$handbook_flag<-add_flag(data$handbook_flag, is.na(data$DateEnd) & left_parliament,
                               "placeholder_end_date")
  data$handbook_flag<-add_flag(data$handbook_flag, data$DateEnd < data$DateStart,
                               "end_before_start")
  data$handbook_flag<-add_flag(data$handbook_flag, !is.na(data$DateStart) & !in_service,
                               "outside_parliamentary_service")

  data<-data|>
    dplyr::select(PHID, DisplayName, Office, Chamber, DateStart, DateEnd, Note, handbook_flag)|>
    dplyr::arrange(Chamber, Office, DateStart)|>
    dplyr::as_tibble()

  if(chamber=="house") data<-data|>dplyr::filter(Chamber=="House")
  if(chamber=="senate") data<-data|>dplyr::filter(Chamber=="Senate")
  if(!is.null(office)) data<-data|>dplyr::filter(Office %in% office)
  attr(data, "scraped")<-scraped
  data
}

# the chamber each officer sat in when their term began; where the start
# date is missing or outside their service, the chamber they sat in closest
# to it; failing that, the chamber the office's name implies
officer_chamber<-function(data, service){
  chamber_of<-c(Member="House", Senator="Senate")
  by_name<-dplyr::case_when(
    grepl("Speaker", data$Office) ~ "House",
    grepl("Senate|President", data$Office) ~ "Senate",
    TRUE ~ NA_character_)
  out<-vapply(seq_len(nrow(data)), function(i){
    terms<-service[service$PHID == data$PHID[i], ]
    if(nrow(terms) == 0) return(by_name[i])
    date<-data$DateStart[i]
    if(is.na(date)) date<-data$DateEnd[i]
    if(is.na(date)) {
      if(!is.na(by_name[i])) return(by_name[i])
      date<-Sys.Date()
    }
    end<-terms$DateEnd
    end[is.na(end)]<-Sys.Date()
    distance<-pmax(as.numeric(terms$DateStart - date), as.numeric(date - end), 0)
    unname(chamber_of[terms$MemberOrSenator[which.min(distance)]])
  }, character(1))
  # an office whose name fixes the chamber keeps it
  ifelse(is.na(by_name), out, by_name)
}

# TRUE where the term starts while the person is in parliament
officer_in_service<-function(data, service){
  vapply(seq_len(nrow(data)), function(i){
    terms<-service[service$PHID == data$PHID[i], ]
    date<-data$DateStart[i]
    if(is.na(date)) return(TRUE)
    end<-terms$DateEnd
    end[is.na(end)]<-Sys.Date()
    any(terms$DateStart <= date & date <= end)
  }, logical(1))
}
