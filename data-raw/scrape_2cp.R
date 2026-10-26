# Scrape two candidate preferred (2CP) results for every House general
# election in inst/extdata/elections.csv and write
# inst/extdata/main_elections_2cp.csv.
#
# Uses the 2CP pair that Elections/Divisions returns inside each division
# (one request per election). The per-division TwoCandidatePreferred endpoint
# used before 1.0.0 is not used: queried by division name and year it also
# returns by-election results from the same parliament, and its percentages
# are then computed across all of them.
#
# The inline pair has no margin or percentage, so both are computed from the
# votes: margin_2cp is the candidate's votes minus their opponent's, and
# margin_percentage_2cp is the candidate's share of the 2CP vote.
# Divisions with no 2CP pair in the Handbook are written to
# data-raw/2cp_missing_divisions.txt; they are filled from other sources in
# inst/extdata/missing_2cp.csv.
# Run from the package root, after build_elections.R.

elections<-readr::read_csv("inst/extdata/elections.csv", show_col_types=FALSE)|>
  dplyr::filter(Reps, !Byelection, !SupplementaryElection)

parties<-rjson::fromJSON(file="https://handbookapi.aph.gov.au/api/parties")$value|>
  lapply(function(p) list(Party=trimws(p$Name), pID=p$pID))|>
  dplyr::bind_rows()

null_to_na<-function(v) if(is.null(v) || length(v)==0) NA else v

list_2cp<-list()
missing<-character()

for(i in seq_len(nrow(elections))){
  year<-elections$Year[i]
  print(paste0("Election Year = ", year))
  divisions<-rjson::fromJSON(file=paste0("https://handbookapi.aph.gov.au/api/Elections/Divisions?year=", year))

  for(division in divisions){
    tcp<-division$TwoCandidatePreferred
    if(length(tcp)<2){
      missing<-c(missing, paste(year, division$Name))
      next
    }
    votes<-vapply(tcp, function(r) as.numeric(null_to_na(r$Votes)), numeric(1))
    list_2cp[[length(list_2cp)+1]]<-dplyr::tibble(
      Id=division$Id, Name=division$Name, State=division$State,
      Year=year, ElectionID=elections$Id[i],
      Candidate=vapply(tcp, function(r) trimws(null_to_na(r$Candidate)), character(1)),
      Party=vapply(tcp, function(r) trimws(null_to_na(r$Party)), character(1)),
      votes_2cp=votes,
      margin_2cp=votes - (sum(votes) - votes),
      margin_percentage_2cp=round(100 * votes / sum(votes), 2),
      swing_2cp=vapply(tcp, function(r) as.numeric(null_to_na(r$Swing)), numeric(1)),
      Status=vapply(tcp, function(r) null_to_na(r$Status), character(1)),
      Note=NA_character_, source=NA_character_)
  }
}

main_elections_2cp<-dplyr::bind_rows(list_2cp)|>
  dplyr::left_join(parties, by="Party")|>
  dplyr::mutate(Status=dplyr::na_if(Status, ""))|>
  dplyr::relocate(pID, .after=Party)

readr::write_csv(main_elections_2cp, "inst/extdata/main_elections_2cp.csv", na="NA")
# preferential voting, and so 2CP results, began at the 1919 election
missing<-missing[as.numeric(substr(missing, 1, 4))>=1919]
writeLines(missing, "data-raw/2cp_missing_divisions.txt")
