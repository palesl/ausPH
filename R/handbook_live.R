# Fetching the tables that ausPH also stores. Used by the get* functions to
# update their stored copy, and by the scripts in data-raw/ to build it, so
# both produce the same layout.

null_to_na <- function(v) if (is.null(v) || length(v) == 0) NA else v

# Parliamentary service for everyone, from the Handbook's records of service
# (record type 9), in the layout of tenures_raw.Rdata. One request.
# Returns NULL if the API cannot be reached.
handbook_parl_service <- function(){
  raw <- fetch_handbook("recordsofservice?$filter=ROSTypeID%20eq%209")
  if (is.null(raw)) return(NULL)
  records <- raw$value
  dplyr::tibble(
    DateStart = vapply(records, function(r) as.character(null_to_na(r$DateStart1)), character(1)),
    DateEnd = vapply(records, function(r) as.character(null_to_na(r$DateEnd1)), character(1)),
    # senators are elected for a state, members for a division
    Electorate = vapply(records, function(r)
      as.character(null_to_na(if (identical(r$MpOrSenator, "Senator")) r$Value1 else r$Value2)),
      character(1)),
    Description = vapply(records, function(r) as.character(null_to_na(r$Text1)), character(1)),
    MemberOrSenator = vapply(records, function(r) as.character(null_to_na(r$MpOrSenator)), character(1)),
    PHID = vapply(records, function(r) as.character(null_to_na(r$PHID)), character(1)),
    DisplayName = vapply(records, function(r) as.character(null_to_na(r$DisplayName)), character(1))
  )
}

# Party service for the given people, from their Parliamentarian/GetTimeline
# pages (one request each; the Handbook has no complete bulk source), in the
# layout of partyService_raw.Rdata. `people` has columns PHID and DisplayName.
# Returns the rows, with the PHIDs that could not be fetched in attr "failed".
handbook_party_service <- function(people, progress = FALSE){
  rows <- vector("list", nrow(people))
  failed <- character()
  for (i in seq_len(nrow(people))) {
    if (progress && i %% 100 == 0) message(i, " of ", nrow(people))
    timeline <- fetch_handbook(paste0("Parliamentarian/GetTimeline?id=", people$PHID[i]),
                               quiet = TRUE)
    if (is.null(timeline)) {
      failed <- c(failed, people$PHID[i])
      next
    }
    party <- records_to_tibble(timeline$PartyService)
    if (nrow(party) == 0) next
    rows[[i]] <- dplyr::tibble(DateStart = as.character(party$DateStart),
                               DateEnd = as.character(party$DateEnd),
                               Party = as.character(party$Party),
                               PartyColour = as.character(party$PartyColour),
                               PHID = people$PHID[i],
                               DisplayName = people$DisplayName[i])
  }
  out <- dplyr::bind_rows(rows)
  attr(out, "failed") <- failed
  out
}

# Every election the Handbook lists, one row each. Returns NULL if the API
# cannot be reached.
handbook_elections <- function(){
  raw <- fetch_handbook("Elections/Elections")
  if (is.null(raw)) return(NULL)
  dplyr::tibble(
    HandbookId = vapply(raw, function(r) as.numeric(r$Id), numeric(1)),
    Year = vapply(raw, function(r) as.numeric(r$Year), numeric(1)),
    DateElection = parse_handbook_date(vapply(raw, function(r) as.character(r$Date), character(1))),
    Division = vapply(raw, function(r) as.character(null_to_na(r$Division)), character(1)),
    Reps = vapply(raw, function(r) isTRUE(r$Reps), logical(1)),
    Senate = vapply(raw, function(r) isTRUE(r$Senate), logical(1))
  )
}

# Rows in the layout of elections.csv for elections from handbook_elections().
# Whether a general election was a double dissolution is not in the
# Handbook's elections list, so FullSenateElection is left NA.
elections_from_handbook <- function(live, parliaments){
  parliament_for <- function(date){
    vapply(date, function(d) {
      pid <- parliaments$PID[parliaments$DateElection <= d]
      if (length(pid) == 0) NA_character_ else paste0("P", max(pid))
    }, character(1))
  }
  general <- is.na(live$Division) & live$Reps & live$Senate
  dplyr::tibble(
    Id = live$HandbookId,
    HandbookId = live$HandbookId,
    Division = ifelse(general, "Federal", live$Division),
    DateElection = live$DateElection,
    Year = live$Year,
    FullSenateElection = NA,
    Parliament = parliament_for(live$DateElection),
    Reps = live$Reps,
    Senate = live$Senate,
    Byelection = !is.na(live$Division),
    SupplementaryElection = is.na(live$Division) & !general
  )
}

# 2CP results for a general election, in the layout of main_elections_2cp.csv.
# Uses the 2CP pair the Handbook returns inside each division of
# Elections/Divisions (one request). The per-division TwoCandidatePreferred
# endpoint is not used: queried by division name and year it also returns
# by-election results from the same parliament, with percentages computed
# across all of them. The inline pair has no margin or percentage, so both are
# computed from the votes. Divisions without a 2CP pair are returned in attr
# "missing". Returns NULL if the API cannot be reached.
handbook_2cp <- function(year, election_id, parties){
  divisions <- fetch_handbook(paste0("Elections/Divisions?year=", year))
  if (is.null(divisions)) return(NULL)

  rows <- list()
  missing <- character()
  for (division in divisions) {
    tcp <- division$TwoCandidatePreferred
    if (length(tcp) < 2) {
      missing <- c(missing, division$Name)
      next
    }
    votes <- vapply(tcp, function(r) as.numeric(null_to_na(r$Votes)), numeric(1))
    rows[[length(rows) + 1]] <- dplyr::tibble(
      Id = division$Id, Name = division$Name, State = division$State,
      Year = year, ElectionID = election_id,
      Candidate = vapply(tcp, function(r) trimws(null_to_na(r$Candidate)), character(1)),
      Party = vapply(tcp, function(r) trimws(null_to_na(r$Party)), character(1)),
      votes_2cp = votes,
      margin_2cp = votes - (sum(votes) - votes),
      margin_percentage_2cp = round(100 * votes / sum(votes), 2),
      swing_2cp = vapply(tcp, function(r) as.numeric(null_to_na(r$Swing)), numeric(1)),
      Status = vapply(tcp, function(r) as.character(null_to_na(r$Status)), character(1)),
      Note = NA_character_, source = NA_character_)
  }
  out <- dplyr::bind_rows(rows)
  if (nrow(out) > 0) {
    out$Status <- dplyr::na_if(out$Status, "")
    out$pID <- parties$pID[match(out$Party, parties$Name)]
    out <- dplyr::relocate(out, "pID", .after = "Party")
  }
  attr(out, "missing") <- missing
  out
}

# 2CP results for a by-election, in the layout of by_elections_2cp.csv, or a
# single row noting that the Handbook has none.
handbook_by_election_2cp <- function(election){
  raw <- fetch_handbook(paste0("Elections/TwoCandidatePreferred?divisionName=undefined&year=undefined&electionId=",
                               election$HandbookId), quiet = TRUE)
  base <- dplyr::tibble(Id = election$Id, Name = election$Division, State = NA_character_,
                        Year = election$Year, ElectionID = election$Id)
  if (length(raw) < 2) {
    return(dplyr::mutate(base, Note = "Missing 2cp from by-election"))
  }
  dplyr::bind_cols(base[rep(1, length(raw)), ], dplyr::tibble(
    Candidate = vapply(raw, function(r) trimws(null_to_na(r$Candidate)), character(1)),
    Party = vapply(raw, function(r) trimws(null_to_na(r$Party)), character(1)),
    votes_2cp = vapply(raw, function(r) as.numeric(null_to_na(r$Votes)), numeric(1)),
    margin_2cp = vapply(raw, function(r) as.numeric(null_to_na(r$Margin)), numeric(1)),
    margin_percentage_2cp = vapply(raw, function(r) as.numeric(null_to_na(r$ThisElectionPercentage)), numeric(1)),
    swing_2cp = vapply(raw, function(r) as.numeric(null_to_na(r$Swing)), numeric(1)),
    Status = dplyr::na_if(vapply(raw, function(r) as.character(null_to_na(r$Status)), character(1)), "")))
}

# the Handbook's parties, with trimmed names, for matching pID by name
handbook_parties <- function(){
  raw <- fetch_handbook("parties")
  if (is.null(raw)) return(NULL)
  dplyr::tibble(pID = vapply(raw$value, function(p) as.numeric(p$pID), numeric(1)),
                Name = vapply(raw$value, function(p) trimws(p$Name), character(1)))
}
