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
