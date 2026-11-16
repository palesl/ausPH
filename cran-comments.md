## Submission

This is an update of ausPH 1.0.1, published on CRAN on 2026-11-12.

It comes sooner than usual because 1.0.1 contains wrong data: two entries
in its table of known errors in the Parliamentary Handbook mark days on
which the Senate sat as days it did not sit, so getSittingDates(apply_errata
= TRUE) returns wrong values. This version corrects them. It also adds one
function, getPresidingOfficers(), and makes the change requested in the
review of 1.0.1 (see below).

## Response to the review of 1.0.1

> Please ensure that your functions do not write by default or in your
> examples/vignettes/tests in the user's home filespace ... -> R/utils.R

The only function that wrote a file, record_scrape_date() in R/utils.R, was
an internal helper used by the scripts that build the package's stored data.
It has been removed from the package and moved to data-raw/ (excluded from
the build). No function, example or test in the package writes files.

## Test environments

* local macOS 26.5 (aarch64), R 4.6.1: R CMD check --as-cran
* win-builder, R-devel: R CMD check --as-cran

## R CMD check results

0 errors | 0 warnings | 1 note

* Days since last update: 4. See "Submission" above for why this update
  comes early.

## Internet resources

The package retrieves data from the Parliamentary Handbook API
(<https://handbookapi.aph.gov.au/>). If the API cannot be reached, functions
return NULL, or the copy of the data stored in the package, with an
informative message rather than an error. Examples that use the API are
wrapped in \donttest{}, and tests that use it are skipped on CRAN and when
offline. getParlService(), getPartyService(), getPresidingOfficers(),
getElections(), get2CP(), getSittingDates() and getErrata() work offline
with update = FALSE. The one function that makes many requests,
getPartyService(update = TRUE), is opt-in and never run in examples or tests.
