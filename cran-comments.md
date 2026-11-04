## Submission

This is a new submission.

## Test environments

* local macOS 26.5 (aarch64), R 4.6.1: R CMD check --as-cran
* win-builder, R-devel (2026-10-26 r90766 ucrt): R CMD check --as-cran

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Internet resources

The package retrieves data from the Parliamentary Handbook API
(<https://handbookapi.aph.gov.au/>). If the API cannot be reached, functions
return NULL, or the copy of the data stored in the package, with an
informative message rather than an error. Examples that use the API are
wrapped in \donttest{}, and tests that use it are skipped on CRAN and when
offline. getParlService(), getPartyService(), getElections(), get2CP(),
getSittingDates() and getErrata() work offline with update = FALSE. The one
function that makes many requests, getPartyService(update = TRUE), is opt-in
and never run in examples or tests.
