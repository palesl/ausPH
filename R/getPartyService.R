#' Data on party service of MPs and senators since 1901
#'
#' Returns the copy of the Handbook's party service records stored in the
#' package. The Handbook has no single source for these records (each
#' person's must be retrieved separately), so updating takes a few minutes and
#' is optional: with `update = TRUE`, the records of everyone who has joined
#' or served in parliament since the stored copy was taken are retrieved again.
#' The date of the stored copy is in the `scraped` attribute of the result,
#' and the date of any update in the `updated` attribute.
#'
#' @param apply_errata if TRUE, replace values listed in [getErrata()] with
#'   their corrected values. By default the Handbook's values are returned.
#'   No party service errata are listed yet, so this currently has no effect.
#' @param update if TRUE, update the stored copy from the Handbook (about
#'   250 requests, two to three minutes). Defaults to FALSE.
#'
#' @return a tibble. `handbook_flag` marks rows with a known problem in the
#'   Handbook: `same_day_party_record` (a one-day record that starts on the
#'   same day as another party record for the same person),
#'   `placeholder_end_date` (the Handbook has 1900-01-01, returned as NA) and
#'   any issue listed in [getErrata()].
#' @export
#'
#' @examples getPartyService()
getPartyService<- function(apply_errata=FALSE, update=FALSE){
  PHID <- DisplayName <- DateStart <- DateEnd <- Party <- PartyColour <-
    handbook_flag <- NULL

  data <- load_extdata("partyService_raw.Rdata")
  scraped <- attr(data, "scraped")
  updated <- NULL
  if(update){
    refreshed<-update_party_service(data, scraped)
    if(!is.null(refreshed)){
      data<-refreshed
      updated<-as.character(Sys.Date())
    }
  }

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
  attr(data, "updated")<-updated
  data
}

# Re-fetch the party service of everyone new to the Handbook since `scraped`
# and everyone with parliamentary service on or after it (whose party may
# have changed), replacing their rows in `stored`. Returns NULL if the
# Handbook cannot be reached.
update_party_service<-function(stored, scraped){
  individuals<-fetch_handbook("individuals?$select=PHID,DisplayName")
  service<-handbook_parl_service()
  if(is.null(individuals) || is.null(service)){
    message("Returning the stored copy of the Handbook instead.")
    return(NULL)
  }
  individuals<-records_to_tibble(individuals$value)

  service_end<-parse_handbook_date(service$DateEnd)
  recent<-unique(service$PHID[is.na(service_end) | service_end >= as.Date(scraped)])
  people<-individuals[individuals$PHID %in% recent | !individuals$PHID %in% stored$PHID, ]

  message("Updating party service for ", nrow(people), " people from the Handbook ",
          "(about ", ceiling(nrow(people) * 0.7 / 60), " minutes)...")
  fresh<-handbook_party_service(people, progress=TRUE)
  failed<-attr(fresh, "failed")
  if(length(failed) > 0){
    message("Could not retrieve ", length(failed), " people; their stored records are kept: ",
            paste(failed, collapse=", "))
  }
  updated_people<-setdiff(people$PHID, failed)
  dplyr::bind_rows(stored[!stored$PHID %in% updated_people, ], fresh)
}
