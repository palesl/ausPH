#' Data on sitting dates in the federal parliament
#'
#' Dates up to the end of the stored copy come from the package; by default,
#' later years are retrieved from the Handbook (one request per year). The
#' date of the stored copy is in the `scraped` attribute of the result, and
#' the date of any update in the `updated` attribute.
#'
#' @param apply_errata if TRUE, replace values listed in [getErrata()] with
#'   their corrected values. By default the Handbook's values are returned.
#' @param update if TRUE (the default), add sitting dates after the stored
#'   copy from the Handbook; if FALSE, use the stored copy only.
#'
#' @return a tibble with one row per sitting date and whether each chamber
#'   sat. `handbook_flag` marks dates listed in [getErrata()], e.g.
#'   `chamber_did_not_sit`.
#' @export
#'
#' @examples
#' \donttest{
#' getSittingDates()
#' }
getSittingDates<-function(apply_errata=FALSE, update=TRUE){
  Date <- RepsSitting <- SenateSitting <- SenateEstimates <- handbook_flag <- NULL

  stored<-load_extdata("sitting_dates.Rdata")
  scraped<-attr(stored, "scraped")
  stored$Date<-parse_handbook_date(stored$Date)
  updated<-NULL

  this_year<-as.numeric(format(Sys.Date(), "%Y"))
  first_live<-as.numeric(format(max(stored$Date), "%Y")) + 1
  live<-list()
  if(update && first_live<=this_year){
    updated<-as.character(Sys.Date())
    for(year in first_live:this_year){
      raw<-fetch_handbook(paste0("StatisticalInformation/SittingDaysForYear?year=", year))
      if(is.null(raw)){
        message("Returning the stored copy of the Handbook instead.")
        live<-list()
        updated<-NULL
        break
      }
      if(length(raw)==0) next
      working<-records_to_tibble(raw)
      working$Date<-parse_handbook_date(working$Date)
      live[[length(live)+1]]<-working
    }
  }

  dat<-dplyr::bind_rows(stored, live)|>
    dplyr::select(Date, RepsSitting, SenateSitting, SenateEstimates)|>
    dplyr::distinct()|>
    dplyr::arrange(Date)

  dat$handbook_flag<-NA_character_
  dat<-apply_errata_table(dat, "sitting_dates", as.character(dat$Date), apply_errata)
  attr(dat, "scraped")<-scraped
  attr(dat, "updated")<-updated
  dat
}
