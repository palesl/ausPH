#' Data on elections since 1901
#'
#' All federal general elections, House by-elections and supplementary
#' elections, excluding elections for casual vacancies in the Senate. The
#' package stores a copy reconciled with the Handbook; by default, any
#' elections the Handbook has listed since are added to it. The date of the
#' stored copy is in the `scraped` attribute of the result, and the date of
#' any update in the `updated` attribute.
#'
#' @param chamber Select from c("all","house","senate")
#' @param byelections Choose to include house by-elections. If byelections = TRUE,
#' then a list of elections with by-elections and their divisions is returned.
#' @param apply_errata if TRUE, replace values listed in [getErrata()] with
#'   their corrected values. By default the Handbook's values are returned.
#' @param update if TRUE (the default), add elections listed in the Handbook
#'   since the stored copy was made (two requests); if FALSE, use the stored
#'   copy only.
#'
#' @return a tibble. `Id` is the package's election identifier (used as
#'   `ElectionID` in [get2CP()]); `HandbookId` is the Handbook's own
#'   identifier, NA for elections the Handbook does not list. For elections
#'   added by an update, `FullSenateElection` is NA, because the Handbook's
#'   list of elections does not say whether an election was a double
#'   dissolution. `handbook_flag` marks elections `not_in_handbook` and issues
#'   listed in [getErrata()].
#' @export
#'
#' @examples
#' getElections(chamber="all", update=FALSE)

getElections<-function(chamber=c("all","house","senate"), byelections=FALSE, apply_errata=FALSE, update=TRUE){
  if(missing(chamber)){
    stop("chamber must be specified")
  }
  chamber<-match.arg(chamber)
  message("All federal elections excluding elections for casual vacancies in the Senate")
  Division <- Reps <- Senate <- Byelection <- NULL

  dat<-elections_table(update)
  updated<-attr(dat, "updated")

  dat$handbook_flag<-NA_character_
  dat$handbook_flag<-add_flag(dat$handbook_flag, is.na(dat$HandbookId), "not_in_handbook")
  dat<-apply_errata_table(dat, "elections", as.character(dat$Id), apply_errata)

  if(chamber=='house') dat<-dat|>dplyr::filter(Reps==TRUE)
  if(chamber=='senate') dat<-dat|>dplyr::filter(Senate==TRUE)
  if(chamber=='senate' || !byelections){
    dat<-dat|>dplyr::filter(Byelection==FALSE)|>dplyr::select(-Division)
  }
  attr(dat, "scraped")<-stored_scrape_date("elections")
  attr(dat, "updated")<-updated
  dat
}

# the stored elections table, plus (if update) elections the Handbook has
# listed since; the date of a successful update is in attr "updated"
elections_table<-function(update){
  DateElection <- Division <- NULL
  file<-system.file("extdata", "elections.csv", package = "ausPH")
  dat<-readr::read_csv(file, show_col_types = FALSE)
  if(!update) return(dat)

  live<-handbook_elections()
  parliaments<-getParliaments()
  if(is.null(live) || is.null(parliaments)){
    message("Returning the stored copy of the Handbook instead.")
    return(dat)
  }
  new<-live[!live$HandbookId %in% dat$HandbookId, ]
  if(nrow(new) > 0){
    message("Adding ", nrow(new), " election(s) listed in the Handbook since ",
            stored_scrape_date("elections"), ".")
    dat<-dplyr::bind_rows(dat, elections_from_handbook(new, parliaments))|>
      dplyr::arrange(DateElection, Division)
  }
  attr(dat, "updated")<-as.character(Sys.Date())
  dat
}
