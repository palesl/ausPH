# Build inst/extdata/elections.csv: every federal general election, House
# by-election and supplementary election since 1901.
#
# Starts from the hand-curated data-raw/ElectionDates.xlsx (which keeps the
# package's own election Id, used as ElectionID in get2CP()) and reconciles it
# with the Handbook's Elections/Elections endpoint:
#  - HandbookId is the Handbook's own Id for the election (NA if it has none);
#  - where the Handbook has the election, its date is used (Handbook errors
#    are corrected through inst/extdata/errata.csv, not here);
#  - elections the Handbook has that the spreadsheet lacks are added, with
#    Id = HandbookId.
# Run from the package root.

curated<-readxl::read_excel("data-raw/ElectionDates.xlsx")
curated$DateElection<-as.Date(curated$DateElection)

live<-rjson::fromJSON(file="https://handbookapi.aph.gov.au/api/Elections/Elections")|>
  lapply(function(r) list(HandbookId=r$Id, Year=r$Year,
                          DateElection=as.Date(substr(r$Date,1,10)),
                          Division=if(is.null(r$Division)) NA_character_ else r$Division,
                          Reps=r$Reps, Senate=r$Senate))|>
  dplyr::bind_rows()

parliaments<-ausPH::getParliaments()

# general elections are matched by date, by-elections by division and year
key<-function(division, year, date) ifelse(is.na(division) | division=="Federal",
                                           paste("general", format(date)),
                                           paste(division, year))
curated$key<-key(curated$Division, curated$Year, curated$DateElection)
live$key<-key(live$Division, live$Year, live$DateElection)

# by-elections where the curated year differs from the Handbook's
# (e.g. Kalgoorlie, Dec 1913 vs Jan 1914) are matched on division and date proximity
unmatched<-which(!curated$key %in% live$key & curated$Byelection)
for(i in unmatched){
  cand<-which(live$Division %in% curated$Division[i] &
                abs(as.numeric(live$DateElection - curated$DateElection[i])) < 120 &
                !live$key %in% curated$key)
  if(length(cand)==1) curated$key[i]<-live$key[cand]
}

out<-curated|>
  dplyr::left_join(dplyr::select(live, key, HandbookId, live_date=DateElection, live_year=Year), by="key")|>
  dplyr::mutate(DateElection=dplyr::coalesce(live_date, DateElection),
                Year=dplyr::coalesce(live_year, Year))|>
  dplyr::select(-live_date, -live_year)

parliament_for<-function(date){
  vapply(date, function(d) paste0("P", max(parliaments$PID[parliaments$DateElection<=d])), character(1))
}

new<-live|>dplyr::filter(!key %in% out$key)|>
  dplyr::mutate(Id=HandbookId,
                Byelection=!is.na(Division),
                SupplementaryElection=is.na(Division) & !(Reps & Senate),
                Division=ifelse(is.na(Division) & Reps & Senate, "Federal", Division),
                FullSenateElection=FALSE,
                Parliament=ifelse(Byelection | SupplementaryElection,
                                  parliament_for(DateElection),
                                  paste0("P", match(DateElection, parliaments$DateElection))))

elections<-dplyr::bind_rows(out, new)|>
  dplyr::select(Id, HandbookId, Division, DateElection, Year, FullSenateElection,
                Parliament, Reps, Senate, Byelection, SupplementaryElection)|>
  dplyr::arrange(DateElection, Division)

readr::write_csv(elections, "inst/extdata/elections.csv", na="")
