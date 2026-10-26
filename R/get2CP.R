#' Data on two candidate preferred results since 1919
#'
#' Results come from a copy of the Handbook stored in the package,
#' supplemented with results the Handbook is missing (documented in the
#' `Note` and `source` columns). A supplementary result is only used where the
#' Handbook has none for that division and year. By default, results for any
#' elections the Handbook has listed since the stored copy was made are added.
#' The date of the stored copy is in the `scraped` attribute of the result,
#' and the date of any update in the `updated` attribute.
#'
#' @param include_byelections Choose to include house by-elections. If
#'   include_byelections = TRUE, by-election results are added.
#' @param update if TRUE (the default), add results for elections listed in
#'   the Handbook since the stored copy was made (three requests, plus one per
#'   new election); if FALSE, use the stored copy only.
#'
#' @return a tibble. `pID` links a candidate's party to [getParties()] where
#'   the Handbook's party name matches a party exactly; otherwise it is NA.
#' @export
#'
#' @examples get2CP(update=FALSE)
get2CP<- function(include_byelections=FALSE, update=TRUE){
  Name <- Year <- margin_percentage_2cp <- NULL

  read_extdata<-function(file){
    readr::read_csv(system.file("extdata", file, package = "ausPH"),
                    show_col_types = FALSE)
  }

  main <- read_extdata("main_elections_2cp.csv")
  missing <- read_extdata("missing_2cp.csv")
  by_elect <- read_extdata("by_elections_2cp.csv")
  updated <- NULL

  if(update){
    new<-new_2cp(main, by_elect, include_byelections)
    if(!is.null(new)){
      main<-dplyr::bind_rows(main, new$main)
      by_elect<-dplyr::bind_rows(by_elect, new$by_elect)
      updated<-as.character(Sys.Date())
    }
  }

  # filling in missing extra info
  missing<-missing |> dplyr::group_by(Year, Name) |>
    dplyr::mutate(Status = dplyr::case_when(margin_percentage_2cp==max(margin_percentage_2cp)~"Elected"))|>
    dplyr::ungroup()

  # supplementary results only where the Handbook has no result
  supplementary<-missing|>
    dplyr::anti_join(main, by=c("Name","Year"))

  message("Notes contain information on results missing from the parliamentary handbook")
  dat<-dplyr::bind_rows(main, supplementary)
  if(include_byelections){
    dat<-dplyr::bind_rows(dat, by_elect)
  }
  attr(dat, "scraped")<-stored_scrape_date("2cp")
  attr(dat, "updated")<-updated
  dat
}

# 2CP results for elections in the Handbook that have none in the stored
# copy: list(main = general elections, by_elect = by-elections), or NULL if
# the Handbook cannot be reached
new_2cp<-function(main, by_elect, include_byelections){
  Reps <- Byelection <- SupplementaryElection <- Id <- Year <- HandbookId <- NULL
  elections<-suppressMessages(elections_table(update=TRUE))
  if(is.null(attr(elections, "updated"))) return(NULL)

  general<-elections|>
    dplyr::filter(Reps, !Byelection, !SupplementaryElection, !Id %in% main$ElectionID,
                  Year >= 1919)
  by<-elections|>
    dplyr::filter(Byelection, !is.na(HandbookId), !Id %in% by_elect$ElectionID)
  if(!include_byelections) by<-by[0, ]
  if(nrow(general) == 0 && nrow(by) == 0) return(list(main=NULL, by_elect=NULL))

  parties<-handbook_parties()
  if(is.null(parties)){
    message("Returning the stored copy of the Handbook instead.")
    return(NULL)
  }
  message("Adding 2CP results for ", nrow(general) + nrow(by), " election(s) listed in the Handbook since ",
          stored_scrape_date("2cp"), ".")
  main_new<-lapply(seq_len(nrow(general)), function(i)
    handbook_2cp(general$Year[i], general$Id[i], parties))
  by_new<-lapply(seq_len(nrow(by)), function(i) handbook_by_election_2cp(by[i, ]))
  list(main=dplyr::bind_rows(main_new), by_elect=dplyr::bind_rows(by_new))
}
