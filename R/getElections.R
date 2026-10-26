#' Data on elections since 1901
#'
#' All federal general elections, House by-elections and supplementary
#' elections, excluding elections for casual vacancies in the Senate.
#'
#' @param chamber Select from c("all","house","senate")
#' @param byelections Choose to include house by-elections. If byelections = TRUE,
#' then a list of elections with by-elections and their divisions is returned.
#' @param apply_errata if TRUE, replace values listed in [getErrata()] with
#'   their corrected values. By default the Handbook's values are returned.
#'
#' @return a tibble. `Id` is the package's election identifier (used as
#'   `ElectionID` in [get2CP()]); `HandbookId` is the Handbook's own
#'   identifier, NA for elections the Handbook does not list. `handbook_flag`
#'   marks elections `not_in_handbook` and issues listed in [getErrata()].
#' @export
#'
#' @examples
#' getElections(chamber="all")

getElections<-function(chamber=c("all","house","senate"), byelections=FALSE, apply_errata=FALSE){
  if(missing(chamber)){
    stop("chamber must be specified")
  }
  chamber<-match.arg(chamber)
  message("All federal elections excluding elections for casual vacancies in the Senate")
  Division <- Reps <- Senate <- Byelection <- NULL

  file<-system.file("extdata", "elections.csv", package = "ausPH")
  dat<- readr::read_csv(file, show_col_types = FALSE)

  dat$handbook_flag<-NA_character_
  dat$handbook_flag<-add_flag(dat$handbook_flag, is.na(dat$HandbookId), "not_in_handbook")
  dat<-apply_errata_table(dat, "elections", as.character(dat$Id), apply_errata)

  if(chamber=='house') dat<-dat|>dplyr::filter(Reps==TRUE)
  if(chamber=='senate') dat<-dat|>dplyr::filter(Senate==TRUE)
  if(chamber=='senate' || !byelections){
    dat<-dat|>dplyr::filter(Byelection==FALSE)|>dplyr::select(-Division)
  }
  dat
}
