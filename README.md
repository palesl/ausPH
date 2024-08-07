
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ausPH <img src="man/figures/ausPH_hex_new.png" align="right" height="139"/>

<!-- badges: start -->
<!-- badges: end -->

The goal of ausPH is to retrieve data from the [Parliamentary Handbook
of the Commonwealth of Australia](https://handbook.aph.gov.au/) and
return ready-to-analyse data, formatted as a `tibble`. The package
relies on the data from the Handbook site, which is still in beta and
subject to change and improvement.

At present, the package contains the following functions:

- `get2CP` (Data on two candidate preferred results since 1919)[^1]
- `getCommitteeMembers` (Data on committee memberships since 1902)
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
- `getMinistries` (Data on Ministries and Governing Parties since 1901)
- `getOccupations` (Data on all pre-parliamentary occupations listed
  since 1901)

## Installation

You can install the development version of ausPH from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("palesl/ausPH")
```

## Citation

Please cite this package as the following:

> Leslie, Pat. 2024. “AusPH: An R Package to Retrieve Data from the
> Parliamentary Handbook of the Commonwealth of Australia.”
> <https://github.com/palesl/ausPH>.

Bibtex format entry:

    @misc{leslie_ausph_2024,
        title = {{ausPH}: {An} {R} package to retrieve data from the {Parliamentary} {Handbook} of the {Commonwealth} of {Australia}.},
        url = {https://github.com/palesl/ausPH},
        author = {Leslie, Pat},
        year = {2024},
        note = {original-date: 2022-07-29T00:58:54Z},
    }

## Examples

These examples show some simple functionality of the package:

``` r
library(ausPH) 
## get elections

getElections(chamber = "all", byelections = T)
#> [1] "All federal elections excluding elections for casual vacancies in the Senate"
#> # A tibble: 211 × 10
#>    Division  DateElection  Year FullSenateElection Parliament    Id Reps  Senate
#>    <chr>     <date>       <dbl> <lgl>              <chr>      <dbl> <lgl> <lgl> 
#>  1 Federal   1901-03-29    1901 TRUE               P1           202 TRUE  TRUE  
#>  2 Darling … 1901-09-14    1901 FALSE              P1           306 TRUE  FALSE 
#>  3 Tasmania  1902-03-26    1902 FALSE              P1           378 TRUE  FALSE 
#>  4 East Syd… 1903-09-04    1903 FALSE              P1           312 TRUE  FALSE 
#>  5 Federal   1903-12-16    1903 FALSE              P2           203 TRUE  TRUE  
#>  6 Wilmot    1904-02-26    1904 FALSE              P2           394 TRUE  FALSE 
#>  7 Melbourne 1904-03-30    1904 FALSE              P2           356 TRUE  FALSE 
#>  8 Riverina  1904-05-18    1904 FALSE              P2           371 TRUE  FALSE 
#>  9 Federal   1906-12-12    1906 FALSE              P3           204 TRUE  TRUE  
#> 10 Echuca    1907-07-10    1907 FALSE              P3           309 TRUE  FALSE 
#> # ℹ 201 more rows
#> # ℹ 2 more variables: Byelection <lgl>, SupplementaryElection <lgl>
```

``` r

## get a list of parliaments

getParliaments()
#> # A tibble: 47 × 8
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
#> # ℹ 37 more rows
#> # ℹ 2 more variables: ParliamentOrdinal <chr>, FQName <chr>
```

``` r

## get two candidate preferred since 1919

get2CP()
#> [1] "Notes contain information on results missing from the parliamentary handbook"
#> # A tibble: 9,308 × 14
#>       Id Name     State  Year ElectionID Candidate    Party votes_2cp margin_2cp
#>    <dbl> <chr>    <chr> <dbl>      <dbl> <chr>        <chr>     <dbl>      <dbl>
#>  1 24373 Adelaide SA     2019        403 GEORGANAS, … Labor     62362      17543
#>  2 24373 Adelaide SA     2019        403 OSBORN, Sha… Libe…     44819     -17543
#>  3 24360 Aston    Vic    2019        403 TUDGE, Alan  Libe…     60180      20270
#>  4 24360 Aston    Vic    2019        403 PETHIYAGODA… Labor     39910     -20270
#>  5 24359 Ballarat Vic    2019        403 VO, Tim      Libe…     40068     -22547
#>  6 24359 Ballarat Vic    2019        403 KING, Cathe… Labor     62615      22547
#>  7 24297 Banks    NSW    2019        403 COLEMAN, Da… Libe…     51609      11488
#>  8 24297 Banks    NSW    2019        403 GAMBIAN, Ch… Labor     40121     -11488
#>  9 24372 Barker   SA     2019        403 PASIN, Tony  Libe…     72851      40036
#> 10 24372 Barker   SA     2019        403 O'BRIEN, Mat Labor     32815     -40036
#> # ℹ 9,298 more rows
#> # ℹ 5 more variables: margin_percentage_2cp <dbl>, swing_2cp <dbl>,
#> #   Status <chr>, Note <chr>, source <chr>
```

## Image Attribution

Hex image icon: Canberra Parliament House by Anna Hatzisavas from [Noun
Project](https://thenounproject.com/browse/icons/term/canberra-parliament-house/ "Canberra Parliament House Icons")

[^1]: The get2CP function does not retrieve live data from the API,
    since retrieval in real time is currently infeasible. In addition,
    some missing elections were identified in the current PH data.
    Therefore the function returns PH data *with* supplementary data
    points, documented in the Note variable.

[^2]: missing elections were filled in, with accompanying new unique
    identifiers.
