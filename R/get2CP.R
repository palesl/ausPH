#' Data on two candidate preferred results since 1919
#'
#' Results come from a stored copy of the Handbook, supplemented with results
#' the Handbook is missing (documented in the `Note` and `source` columns).
#' A supplementary result is only used where the Handbook has none for that
#' division and year.
#'
#' @param include_byelections Choose to include house by-elections. If
#'   include_byelections = TRUE, by-election results are added.
#'
#' @return a tibble. `pID` links a candidate's party to [getParties()] where
#'   the Handbook's party name matches a party exactly; otherwise it is NA.
#' @export
#'
#' @examples get2CP()
get2CP<- function(include_byelections=FALSE){
  Name <- Year <- margin_percentage_2cp <- NULL

  read_extdata<-function(file){
    readr::read_csv(system.file("extdata", file, package = "ausPH"),
                    show_col_types = FALSE)
  }

  main <- read_extdata("main_elections_2cp.csv")
  missing <- read_extdata("missing_2cp.csv")

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
    dat<-dplyr::bind_rows(dat, read_extdata("by_elections_2cp.csv"))
  }
  dat
}
