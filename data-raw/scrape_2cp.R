# Scrape two candidate preferred (2CP) results for every House general
# election in inst/extdata/elections.csv and write
# inst/extdata/main_elections_2cp.csv.
#
# Uses handbook_2cp() (R/handbook_live.R), the same function get2CP() uses to
# add new elections; see it for how the results are taken from the Handbook.
# Divisions with no 2CP pair in the Handbook are written to
# data-raw/2cp_missing_divisions.txt; they are filled from other sources in
# inst/extdata/missing_2cp.csv.
# Run from the package root, after build_elections.R.

devtools::load_all()

elections<-readr::read_csv("inst/extdata/elections.csv", show_col_types=FALSE)|>
  dplyr::filter(Reps, !Byelection, !SupplementaryElection, Year >= 1919)

parties<-handbook_parties()

results<-list()
missing<-character()
for(i in seq_len(nrow(elections))){
  print(paste0("Election Year = ", elections$Year[i]))
  result<-handbook_2cp(elections$Year[i], elections$Id[i], parties)
  if(is.null(result)) stop("Could not reach the Handbook API.")
  if(length(attr(result, "missing"))>0){
    missing<-c(missing, paste(elections$Year[i], attr(result, "missing")))
  }
  results[[i]]<-result
}

main_elections_2cp<-dplyr::bind_rows(results)
readr::write_csv(main_elections_2cp, "inst/extdata/main_elections_2cp.csv", na="NA")
record_scrape_date("2cp")
writeLines(missing, "data-raw/2cp_missing_divisions.txt")
