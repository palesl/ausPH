# ausPH 1.0.1

## Live updates

* Functions backed by a stored copy of the Handbook now bring it up to date,
  as `getSittingDates()` already did, through a new `update` argument:
  * `getParlService()` retrieves the whole table from the Handbook's records
    of service in a single request (previously 1,881 requests). This source is
    also more accurate: the per-person timelines used before list two
    senators appointed in August 2026 as House members with no electorate.
  * `getElections()` adds elections the Handbook has listed since the stored
    copy. Their `FullSenateElection` is NA, as the Handbook's list does not
    say whether an election was a double dissolution.
  * `get2CP()` adds 2CP results for those elections.
  * `getPartyService(update = TRUE)` re-fetches the records of everyone who
    has joined or served in parliament since the stored copy. The Handbook
    has no bulk source for party service (its records of service leave most
    party dates blank), so this takes about 250 requests and is off by
    default.
* `update` defaults to `TRUE` except for `getPartyService()`. With
  `update = FALSE`, or when the Handbook cannot be reached, the stored copy
  is returned (with a message in the second case). The date of any update is
  in a new `updated` attribute.
* The stored tables and the updates are built by the same functions, so they
  have the same layout; the scripts in `data-raw/` now use them.
* `getParlService()`: `placeholder_end_date` now flags only terms that are
  not the member's latest. The Handbook's records of service use 1900-01-01
  for every term that has not ended, which is returned as NA as before.

## Other changes

* `getOccupations()`, `getQualifications()` and `getSchools()` now return
  tibbles, like every other function.
* `get2CP()` and `getElections()` now record the date their stored copy was
  taken from the Handbook in the `scraped` attribute, like
  `getParlService()`, `getPartyService()` and `getSittingDates()`.
* README: the data map is redrawn from the package's actual columns and
  keys (its source is `data-raw/data_map.tex`), and out-of-date statements
  are corrected.
* Documented a change from 1.0.0 that was missing from its notes:
  `getParliaments()` now returns `ParliamentNext`, the `PID` of the
  following parliament.

# ausPH 1.0.0

First major release. All stored data refreshed from the Parliamentary
Handbook on 26 October 2026. This release follows a review of every issue
raised by linking ausPH to Hansard speech data: each was traced to the
package, its stored data, the Handbook or Hansard, and the package's share
fixed here.

## Breaking changes

* R (>= 4.1.0) is now required (the package uses the native pipe).
* `get2CP()`: `Party` now holds the Handbook's full party name (e.g.
  "Australian Labor Party" rather than "Labor") and a new `pID` column links
  it to `getParties()` where the name matches exactly (83% of rows).
  Hand-filled rows in `missing_2cp.csv` keep their original party labels.
* `getElections()` reads a new `elections.csv` in place of `ElectionDates.xlsx`
  and gains `HandbookId` (the Handbook's own election id) and
  `handbook_flag`. `Id` is unchanged, so joins on `ElectionID` still work.
* `getMinistries()` gains `pID`, and ministries with no listed party are
  kept with `Party = NA` (previously they were dropped).
* `getParlService()`, `getPartyService()` and `getSittingDates()` gain a
  `handbook_flag` column; `getSittingDates()` returns `Date` as a `Date`
  and drops the internal `year_id` column.
* `getSchools()`, `getOccupations()` and `getQualifications()` no longer
  return rows with empty values.
* API functions return `NULL` with a message, instead of an error, when the
  Handbook API cannot be reached.

## Handbook errors: flags and errata

* New `getErrata()` returns a table of known errors in the Handbook, with the
  corrected value, the evidence and a source. It covers 14 errors so far:
  overlapping service terms (Calwell, Gietzelt, Rosevear, Fry, Fairbairn),
  sittings recorded for chambers that did not sit (Senate 14 March 1928 and
  17 March 1997, House 5 February 2008), and six by-election dates that
  contradict the Handbook's own tenure records (Tasmania 1902, Kooyong 1910,
  Kalgoorlie 1940, Fremantle 1945, and East Sydney and Grey 1963, which
  the Handbook has swapped).
* By default every function returns the Handbook's values and marks affected
  rows in `handbook_flag`. `getParlService()`, `getPartyService()`,
  `getSittingDates()` and `getElections()` take `apply_errata = TRUE` to
  substitute the corrected values. An erratum only applies while the Handbook
  still has the wrong value, so it stops applying once the Handbook is fixed.
* Rule-based flags: `overlapping_term` and `placeholder_end_date`
  (`getParlService()`), `same_day_party_record` (`getPartyService()`) and
  `not_in_handbook` (`getElections()`).

## Bug fixes

* `getMinisters()` and `getShadowMinisters()`: `MDateStart` and `MDateEnd`
  were `NA` for every row after the Handbook changed its date format. Dates
  are now parsed whatever format the Handbook uses.
* `getMinistries()` dropped the first Barton Ministry (the Handbook lists no
  party for it), so joins from `getMinisters()` on `MID` found no ministry.
* `get2CP()`: 42 division-years had 4 or 8 rows instead of 2. The original
  scrape also picked up by-election results for the same division and
  parliament, and the Handbook's percentages for those rows were computed
  across all of them (e.g. Lindsay 1996 showed 26% rather than 52%).
  Results now come from one clean pair per division, with margin and
  percentage computed from the votes.
* The Handbook's placeholder date 1900-01-01 is now returned as `NA`
  (affected open-ended committee memberships and some service records).
* `getParties()` trims the trailing whitespace the Handbook adds to 27 party
  abbreviations (e.g. `"NP "`), which broke exact matching.
* `getParlService()` errored if `chamber` was not supplied; it now defaults
  to `"all"`.
* `getSittingDates()` and `getPartyService()` returned their result
  invisibly; `getCommitteeMembers()` joined without a key.
* `print()` status output replaced with `message()`.

## Data updates

* Parliamentary and party service re-scraped. The Handbook has corrected 16
  people's tenures since the previous scrape, including Pearce and
  E.J. Russell, whose 1907–1913 Senate terms had been stored with a
  1900-01-01 end date (about 12,000 speech-linkage records were affected).
  Four individuals missing from the previous scrape are now included,
  among them Senator Sean Bell (from 18 September 2025).
* Elections: added the 2022 and 2025 general elections; the Aston and
  Fadden (2023) and Dunkley and Cook (2024) by-elections; and the 2014 WA
  Senate election. The by-elections previously added by hand with ids
  9001–9008 are matched to their Handbook ids where the Handbook now has
  them. Election dates come from the Handbook, which corrects the earlier
  dates for Kalgoorlie 1913 (22 December 1913), Cunningham 1956 and
  Dalley 1915.
* 2CP: added 2022 and 2025. The Handbook now records the actual final two
  candidates in about 100 seats where it previously had Labor-versus-Coalition
  counts (e.g. Blair 1998, Calare 1996), and now includes 2001, so the
  supplementary 2001 results built from AEC files are retired. 2CP results
  for the 2023 and 2024 by-elections are not yet in the Handbook and are
  marked as missing.
* Sitting dates stored through 2025; later years are fetched live.

## Internal

* Scrape and build scripts moved to `data-raw/`, re-runnable from the
  package root, and stop rather than save a partial scrape. Stored tables
  record their scrape date in the `scraped` attribute.
* Shared helpers for API access and date parsing; tests added for parsing,
  flags, errata and stored data, with API tests skipped offline and on CRAN.

# ausPH 0.0.0.9004

* Data update, 8 September 2025; `getSittingDates()` and `getSchools()` added.
