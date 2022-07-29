
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ausPH <img src='man/figures/ausPH_hex.png' align="right" height="139" />

<!-- badges: start -->
<!-- badges: end -->

The goal of ausPH is to retrieve data from the [Parliamentary Library’s
Handbook website](https://handbook.aph.gov.au/). The first example is a
call to produce a list of elections in the Australian Parliament since
Federation.

## Installation

You can install the development version of ausPH from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("palesl/ausPH")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(ausPH)
## get elections in Australia

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
```
