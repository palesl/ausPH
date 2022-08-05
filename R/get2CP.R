#' Get two candidate preferred results since 1919
#'
#' @param include_byelections Choose to include house by-elections. If .byelections = TRUE,
#' then a list of elections with by-elections and their divisions is returned.
#'
#' @return a tibble
#' @export
#'
#' @examples get2CP()
get2CP<- function(include_byelections=F){

  main <-         system.file("extdata", "main_elections_2cp.csv", package = "ausPH")
  election_2001<- system.file("extdata", "results_2001_2cp.csv", package = "ausPH")
  missing <-      system.file("extdata", "missing_2cp.csv", package = "ausPH")

  main<- readr::read_csv(main, show_col_types = FALSE)
  election_2001<- readr::read_csv(election_2001, show_col_types = FALSE)
  missing<- readr::read_csv(missing, show_col_types = FALSE)

  print("Notes contain information on results missing from the parliamentary handbook")
  if(include_byelections==F){
    dat<-dplyr::bind_rows(main, election_2001, missing)
    return(dat)
  }
  if(include_byelections==T){
    by_elect <- system.file("extdata", "by_elections_2cp.csv", package = "ausPH")
    by_elect<- readr::read_csv(by_elect, show_col_types = FALSE)
    dat<-dplyr::bind_rows(main, election_2001, missing, by_elect)
    return(dat)
  }
}


