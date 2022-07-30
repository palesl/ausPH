
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ausPH <img src='man/figures/ausPH_hex.png' align="right" height="139" />

<!-- badges: start -->
<!-- badges: end -->

The goal of ausPH is to retrieve data from the [Parliamentary Handbook
of the Commonwealth of Australia](https://handbook.aph.gov.au/). The
first example is a call to produce a list of elections in the Australian
Parliament since Federation.

## Installation

You can install the development version of ausPH from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("palesl/ausPH")
```

## Example

These examples show some simple functionality of the package:

``` r
library(ausPH)
## get elections

getElections(chamber = "all", byelections = T)
#> # A tibble: 202 × 6
#>    `$id`    Id  Year Division    Reps  Senate
#>    <chr> <dbl> <dbl> <chr>       <lgl> <lgl> 
#>  1 1       278  2020 Eden-Monaro TRUE  FALSE 
#>  2 2       279  2020 Groom       TRUE  FALSE 
#>  3 3       403  2019 <NA>        TRUE  TRUE  
#>  4 4       273  2018 Fremantle   TRUE  FALSE 
#>  5 5       274  2018 Longman     TRUE  FALSE 
#>  6 6       271  2018 Batman      TRUE  FALSE 
#>  7 7       272  2018 Braddon     TRUE  FALSE 
#>  8 8       275  2018 Mayo        TRUE  FALSE 
#>  9 9       276  2018 Perth       TRUE  FALSE 
#> 10 10      277  2018 Wentworth   TRUE  FALSE 
#> # … with 192 more rows

## get a list of parliaments

getParliaments()
#> # A tibble: 47 × 7
#>      PID Name   DateElection DateOpening DateDissolution ParliamentEnd FQName   
#>    <dbl> <chr>  <date>       <date>      <date>          <date>        <chr>    
#>  1     1 First… 1901-03-29   1901-05-09  1903-11-23      1903-12-15    First Pa…
#>  2     2 Secon… 1903-12-16   1904-03-02  1906-11-05      1906-12-11    Second P…
#>  3     3 Third… 1906-12-12   1907-02-20  1910-02-19      1910-04-12    Third Pa…
#>  4     4 Fourt… 1910-04-13   1910-07-01  1913-04-23      1913-05-30    Fourth P…
#>  5     5 Fifth… 1913-05-31   1913-07-09  1914-07-30      1914-09-04    Fifth Pa…
#>  6     6 Sixth… 1914-09-05   1914-10-08  1917-03-26      1917-05-04    Sixth Pa…
#>  7     7 Seven… 1917-05-05   1917-06-14  1919-11-03      1919-12-12    Seventh …
#>  8     8 Eight… 1919-12-13   1920-02-26  1922-11-06      1922-12-15    Eighth P…
#>  9     9 Ninth… 1922-12-16   1922-02-28  1925-10-03      1925-11-13    Ninth Pa…
#> 10    10 Tenth… 1925-11-14   1926-01-13  1928-10-09      1928-11-16    Tenth Pa…
#> # … with 37 more rows
```
