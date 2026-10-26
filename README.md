
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ausPH <img src="man/figures/ausPH_hex_new.png" align="right" height="139"/>

<!-- badges: start -->

<!-- badges: end -->

The goal of ausPH is to retrieve data from the [Parliamentary Handbook
of the Commonwealth of Australia](https://handbook.aph.gov.au/) and
return ready-to-analyse data, formatted as a `tibble`. The package
relies on the data from the Handbook site, which is subject to change
and improvement. Functions that query the Handbook’s API return `NULL`,
with a message, if the API cannot be reached.

At present, the package contains the following functions:

- `get2CP` (Data on two candidate preferred results since 1919)[^1]
- `getCommitteeMembers` (Data on committee memberships since 1901)
- `getElections` (Data on elections since 1901)[^2]
- `getElectorates` (Data on electorates since 1901)
- `getIndividuals` (Data on individuals and biographical information
  since 1901)
- `getParlService` (data on parliamentary tenures of MPs and senators
  since 1901)
- `getParliaments` (Data on Parliamentary terms since 1901)
- `getMinisters` (Data on Ministers since 1901)
- `getShadowMinisters` (Data on Shadow Ministers since 1901)
- `getParties` (Data on Parties since 1901)
- `getPartyService` (Data on Party Service of MPs and Senators since
  1901) 
- `getMinistries` (Data on Ministries and Governing Parties since
  1901) 
- `getOccupations` (Data on all pre-parliamentary occupations listed
  since 1901)
- `getQualifications` (Data on all listed qualifications)
- `getSchools` (Data on all listed secondary schools)
- `getSittingDates` (Data on all parliamentary sitting dates since
  1901) 
- `getErrata` (Known errors in the Handbook, with corrections)

## Data map

How the tables returned by ausPH link together. Hansard speeches are in
development.

<img src="man/figures/data_map.png" alt="Diagram of the tables returned by ausPH and the keys that link them" width="100%"/>

The diagram is drawn from `data-raw/data_map.tex`.

## Errors in the Handbook

The Handbook is an excellent source, but it contains some errors. ausPH
returns the Handbook’s data as it is by default, and marks rows with a
known problem in a `handbook_flag` column, for example terms that
overlap the member’s previous term, or sittings recorded for a chamber
that did not sit.

The flag column is returned by `getParlService()`, `getPartyService()`,
`getSittingDates()` and `getElections()`. Where the correct value is
known, it is listed with its evidence in `getErrata()`, and passing
`apply_errata = TRUE` to these functions uses the corrected value
instead (no corrections are listed yet for `getPartyService()`):

``` r
getParlService(chamber = "house", apply_errata = TRUE)
```

If you find another error, please [open an
issue](https://github.com/palesl/ausPH/issues).

## Stored data and updates

Some tables would take many requests to retrieve from the Handbook in
full, so the package stores a copy and, by default, brings it up to date
when you call the function:

| Function | By default | Requests |
|----|----|----|
| `getParlService()` | retrieves the whole table from the Handbook | 1 |
| `getElections()` | adds elections listed since the stored copy | 2 |
| `get2CP()` | adds results for elections since the stored copy | about 3, plus 1 per new election |
| `getSittingDates()` | adds sitting dates after the stored copy | 1 per year |
| `getPartyService()` | stored copy only; `update = TRUE` re-fetches everyone who has served since (about 250 requests, two to three minutes) | 0 |

Use `update = FALSE` to work from the stored copy alone, e.g. offline or
for reproducibility. If the Handbook cannot be reached, these functions
return the stored copy with a message. The date of the stored copy is in
the `scraped` attribute and the date of any update in the `updated`
attribute, e.g. `attr(getElections("all"), "updated")`.

## Installation

You can install the development version of ausPH from
[GitHub](https://github.com/palesl/ausPH) with
[pak](https://pak.r-lib.org/):

``` r
# install.packages("pak")
pak::pak("palesl/ausPH")
```

or, if you already use it, with `remotes`:

``` r
# install.packages("remotes")
remotes::install_github("palesl/ausPH")
```

## Citation

Please cite this package as the following:

> Leslie, Pat. 2026. “ausPH: An R Package to Retrieve Data from the
> Parliamentary Handbook of the Commonwealth of Australia.” R package
> version 1.0.1. <https://github.com/palesl/ausPH>.

Bibtex format entry:

    @misc{leslie_ausph_2026,
        title = {{ausPH}: {An} {R} package to retrieve data from the {Parliamentary} {Handbook} of the {Commonwealth} of {Australia}.},
        url = {https://github.com/palesl/ausPH},
        author = {Leslie, Pat},
        year = {2026},
        note = {R package version 1.0.1},
    }

## Examples

These examples show some simple functionality of the package:

``` r
library(ausPH) 
## get elections

getElections(chamber = "all", byelections = T)
#> All federal elections excluding elections for casual vacancies in the Senate
#> # A tibble: 218 × 12
#>       Id HandbookId Division    DateElection  Year FullSenateElection Parliament
#>    <dbl>      <dbl> <chr>       <date>       <dbl> <lgl>              <chr>     
#>  1   202        202 Federal     1901-03-29    1901 TRUE               P1        
#>  2   306        306 Darling Do… 1901-09-14    1901 FALSE              P1        
#>  3   378        378 Tasmania    1902-03-06    1902 FALSE              P1        
#>  4   312        312 East Sydney 1903-09-04    1903 FALSE              P1        
#>  5   203        203 Federal     1903-12-16    1903 FALSE              P2        
#>  6   394        394 Wilmot      1904-02-26    1904 FALSE              P2        
#>  7   356        356 Melbourne   1904-03-30    1904 FALSE              P2        
#>  8   371        371 Riverina    1904-05-18    1904 FALSE              P2        
#>  9   204        204 Federal     1906-12-12    1906 FALSE              P3        
#> 10   309        309 Echuca      1907-07-10    1907 FALSE              P3        
#> # ℹ 208 more rows
#> # ℹ 5 more variables: Reps <lgl>, Senate <lgl>, Byelection <lgl>,
#> #   SupplementaryElection <lgl>, handbook_flag <chr>

## get a list of parliaments

getParliaments()
#> # A tibble: 48 × 9
#>      PID Name             DateElection DateOpening DateDissolution ParliamentEnd
#>    <dbl> <chr>            <date>       <date>      <date>          <date>       
#>  1     1 First Parliament 1901-03-29   1901-05-09  1903-11-23      1903-12-15   
#>  2     2 Second Parliame… 1903-12-16   1904-03-02  1906-11-05      1906-12-11   
#>  3     3 Third Parliament 1906-12-12   1907-02-20  1910-02-19      1910-04-12   
#>  4     4 Fourth Parliame… 1910-04-13   1910-07-01  1913-04-23      1913-05-30   
#>  5     5 Fifth Parliament 1913-05-31   1913-07-09  1914-07-30      1914-09-04   
#>  6     6 Sixth Parliament 1914-09-05   1914-10-08  1917-03-26      1917-05-04   
#>  7     7 Seventh Parliam… 1917-05-05   1917-06-14  1919-11-03      1919-12-12   
#>  8     8 Eighth Parliame… 1919-12-13   1920-02-26  1922-11-06      1922-12-15   
#>  9     9 Ninth Parliament 1922-12-16   1923-02-28  1925-10-03      1925-11-13   
#> 10    10 Tenth Parliament 1925-11-14   1926-01-13  1928-10-09      1928-11-16   
#> # ℹ 38 more rows
#> # ℹ 3 more variables: ParliamentNext <dbl>, ParliamentOrdinal <chr>,
#> #   FQName <chr>

## get two candidate preferred since 1919

get2CP()
#> Notes contain information on results missing from the parliamentary handbook
#> # A tibble: 9,746 × 15
#>       Id Name  State  Year ElectionID Candidate Party   pID votes_2cp margin_2cp
#>    <dbl> <chr> <chr> <dbl>      <dbl> <chr>     <chr> <dbl>     <dbl>      <dbl>
#>  1 19855 Adel… SA     1919        209 Yates, E… Aust…     1     10184       -339
#>  2 19855 Adel… SA     1919        209 Blundell… Nati…    NA     10523        339
#>  3 19839 Angas SA     1919        209 Gabb, Mo… Aust…     1      9468        251
#>  4 19839 Angas SA     1919        209 Glynn, P… Nati…    NA      9217       -251
#>  5 19840 Bala… Vic    1919        209 Smith, P… Aust…     1     11495      -9760
#>  6 19840 Bala… Vic    1919        209 Watt, Wi… Nati…    NA     21255       9760
#>  7 19841 Ball… Vic    1919        209 McGrath,… Aust…     1     13568         -1
#>  8 19841 Ball… Vic    1919        209 Kerby, E… Nati…    NA     13569          1
#>  9 19842 Bark… SA     1919        209 Davies, … Aust…     1      7923      -6223
#> 10 19842 Bark… SA     1919        209 Livingst… Nati…    NA     14146       6223
#> # ℹ 9,736 more rows
#> # ℹ 5 more variables: margin_percentage_2cp <dbl>, swing_2cp <dbl>,
#> #   Status <chr>, Note <chr>, source <chr>

## known errors in the Handbook

getErrata()
#> # A tibble: 14 × 9
#>    table        key   field handbook_value corrected_value issue evidence source
#>    <chr>        <chr> <chr> <chr>          <chr>           <chr> <chr>    <chr> 
#>  1 parl_service BV8|… Date… 1946-06-28     1946-09-28      over… Term st… https…
#>  2 parl_service RG4|… Date… 1975-05-18     1974-05-18      over… Term en… https…
#>  3 parl_service L08|… Date… 1940-08-21     1940-09-21      over… Term st… https…
#>  4 parl_service JXQ|… Date… 1977-11-10     1977-12-10      over… Term st… https…
#>  5 parl_service KDT|… Date… 1972-11-02     1972-12-02      over… Term st… https…
#>  6 sitting_dat… 1928… Sena… TRUE           FALSE           cham… Only th… https…
#>  7 sitting_dat… 1997… Sena… TRUE           FALSE           cham… Canberr… https…
#>  8 sitting_dat… 2008… Reps… TRUE           FALSE           cham… The 42n… https…
#>  9 elections    378   Date… 1902-03-06     1902-03-26      date… The Han… https…
#> 10 elections    343   Date… 1910-08-29     1910-08-24      date… The Han… https…
#> 11 elections    341   Date… 1940-11-10     1940-11-16      date… The Han… https…
#> 12 elections    9004  Date… 1945-10-18     1945-08-18      date… The Han… https…
#> 13 elections    315   Date… 1963-06-01     1963-09-28      date… The Han… https…
#> 14 elections    327   Date… 1963-09-28     1963-06-01      date… The Han… https…
#> # ℹ 1 more variable: date_added <chr>
```

Last updated: 26 October 2026. See `NEWS.md` for changes.

## Image Attribution

Hex image icon: Canberra Parliament House by Anna Hatzisavas from [Noun
Project](https://thenounproject.com/browse/icons/term/canberra-parliament-house/ "Canberra Parliament House Icons")

[^1]: `get2CP()` returns a stored copy of the Handbook’s results, with
    any elections held since added from the Handbook (see below). Where
    the Handbook has no result for a division, a result from another
    source is used instead, documented in the `Note` and `source`
    variables.

[^2]: Two elections the Handbook does not list (the Wide Bay by-election
    of 1928 and the Dickson supplementary election of 1993) are added,
    with the package’s own identifiers and flagged `not_in_handbook`.
    `HandbookId` gives the Handbook’s own identifier for every other
    election.
