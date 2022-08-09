
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ausPH <img src="man/figures/ausPH_hex.png" align="right" height="139"/>

<!-- badges: start -->
<!-- badges: end -->

The goal of ausPH is to retrieve data from the [Parliamentary Handbook
of the Commonwealth of Australia](https://handbook.aph.gov.au/) and
return ready-to-analyse data, formatted as a `tibble`. The data relies
on the data from the Handbook site, which is still in beta and subject
to change and improvement.

At present, the package contains the following functions:

-   `get2CP` (Data on two candidate preferred results since 1919)[^1]
-   `getCommitteeMembers` (Data on committee memberships since 1902)
-   `getElections` (Data on elections since 1901)[^2]
-   `getElectorates` (Data on electorates since 1901)
-   `getIndividuals` (Data on individuals and biographical information
    since 1901)
-   `getParliaments` (Data on Parliamentary terms since 1901)

## Installation

You can install the development version of ausPH from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("palesl/ausPH")
```

## Examples

These examples show some simple functionality of the package:

``` r
library(ausPH) 
## get elections

getElections(chamber = "all", byelections = T)
#> [1] "All federal elections excluding elections for casual vacancies in the Senate"
#> # A tibble: 211 × 10
#>    Division  DateElec…¹  Year FullS…² Parli…³    Id Reps  Senate Byele…⁴ Suppl…⁵
#>    <chr>     <date>     <dbl> <lgl>   <chr>   <dbl> <lgl> <lgl>  <lgl>   <lgl>  
#>  1 Federal   1901-03-29  1901 TRUE    P1        202 TRUE  TRUE   FALSE   FALSE  
#>  2 Darling … 1901-09-14  1901 FALSE   P1        306 TRUE  FALSE  TRUE    FALSE  
#>  3 Tasmania  1902-03-26  1902 FALSE   P1        378 TRUE  FALSE  TRUE    FALSE  
#>  4 East Syd… 1903-09-04  1903 FALSE   P1        312 TRUE  FALSE  TRUE    FALSE  
#>  5 Federal   1903-12-16  1903 FALSE   P2        203 TRUE  TRUE   FALSE   FALSE  
#>  6 Wilmot    1904-02-26  1904 FALSE   P2        394 TRUE  FALSE  TRUE    FALSE  
#>  7 Melbourne 1904-03-30  1904 FALSE   P2        356 TRUE  FALSE  TRUE    FALSE  
#>  8 Riverina  1904-05-18  1904 FALSE   P2        371 TRUE  FALSE  TRUE    FALSE  
#>  9 Federal   1906-12-12  1906 FALSE   P3        204 TRUE  TRUE   FALSE   FALSE  
#> 10 Echuca    1907-07-10  1907 FALSE   P3        309 TRUE  FALSE  TRUE    FALSE  
#> # … with 201 more rows, and abbreviated variable names ¹​DateElection,
#> #   ²​FullSenateElection, ³​Parliament, ⁴​Byelection, ⁵​SupplementaryElection
#> # ℹ Use `print(n = ...)` to see more rows

## get a list of parliaments

getParliaments()
#> # A tibble: 47 × 7
#>      PID Name               DateElection DateOpen…¹ DateDiss…² Parliame…³ FQName
#>    <dbl> <chr>              <date>       <date>     <date>     <date>     <chr> 
#>  1     1 First Parliament   1901-03-29   1901-05-09 1903-11-23 1903-12-15 First…
#>  2     2 Second Parliament  1903-12-16   1904-03-02 1906-11-05 1906-12-11 Secon…
#>  3     3 Third Parliament   1906-12-12   1907-02-20 1910-02-19 1910-04-12 Third…
#>  4     4 Fourth Parliament  1910-04-13   1910-07-01 1913-04-23 1913-05-30 Fourt…
#>  5     5 Fifth Parliament   1913-05-31   1913-07-09 1914-07-30 1914-09-04 Fifth…
#>  6     6 Sixth Parliament   1914-09-05   1914-10-08 1917-03-26 1917-05-04 Sixth…
#>  7     7 Seventh Parliament 1917-05-05   1917-06-14 1919-11-03 1919-12-12 Seven…
#>  8     8 Eighth Parliament  1919-12-13   1920-02-26 1922-11-06 1922-12-15 Eight…
#>  9     9 Ninth Parliament   1922-12-16   1922-02-28 1925-10-03 1925-11-13 Ninth…
#> 10    10 Tenth Parliament   1925-11-14   1926-01-13 1928-10-09 1928-11-16 Tenth…
#> # … with 37 more rows, and abbreviated variable names ¹​DateOpening,
#> #   ²​DateDissolution, ³​ParliamentEnd
#> # ℹ Use `print(n = ...)` to see more rows

## get two candidate preferred since 1919

get2CP()
#> [1] "Notes contain information on results missing from the parliamentary handbook"
#> # A tibble: 9,308 × 14
#>       Id Name  State  Year Elect…¹ Candi…² Party votes…³ margi…⁴ margi…⁵ swing…⁶
#>    <dbl> <chr> <chr> <dbl>   <dbl> <chr>   <chr>   <dbl>   <dbl>   <dbl>   <dbl>
#>  1 24373 Adel… SA     2019     403 GEORGA… Labor   62362   17543    58.2   -0.12
#>  2 24373 Adel… SA     2019     403 OSBORN… Libe…   44819  -17543    41.8    0.12
#>  3 24360 Aston Vic    2019     403 TUDGE,… Libe…   60180   20270    60.1    2.72
#>  4 24360 Aston Vic    2019     403 PETHIY… Labor   39910  -20270    39.9   -2.72
#>  5 24359 Ball… Vic    2019     403 VO, Tim Libe…   40068  -22547    39.0   -3.62
#>  6 24359 Ball… Vic    2019     403 KING, … Labor   62615   22547    61.0    3.62
#>  7 24297 Banks NSW    2019     403 COLEMA… Libe…   51609   11488    56.3    4.82
#>  8 24297 Banks NSW    2019     403 GAMBIA… Labor   40121  -11488    43.7   -4.82
#>  9 24372 Bark… SA     2019     403 PASIN,… Libe…   72851   40036    68.9    5.07
#> 10 24372 Bark… SA     2019     403 O'BRIE… Labor   32815  -40036    31.1   -5.07
#> # … with 9,298 more rows, 3 more variables: Status <chr>, Note <chr>,
#> #   source <chr>, and abbreviated variable names ¹​ElectionID, ²​Candidate,
#> #   ³​votes_2cp, ⁴​margin_2cp, ⁵​margin_percentage_2cp, ⁶​swing_2cp
#> # ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
```

[^1]: The get2CP function does not retrieve live data from the API,
    since retrieval in real time is currently infeasible. In addition,
    some missing elections were identified in the current PH data.
    Therefore the function returns PH data *with* supplementary data
    points, documented in the Note variable.

[^2]: missing elections were filled in, with accompanying new unique
    identifiers.
