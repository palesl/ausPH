## Submission

This is a new submission.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Internet resources

Most functions query the Parliamentary Handbook API
(<https://handbookapi.aph.gov.au/>). If the API cannot be reached they return
NULL with an informative message rather than an error. Examples that use the
API are wrapped in \donttest{}, and tests that use it are skipped on CRAN and
when offline. Functions based on the data stored in the package
(getParlService(), getPartyService(), getElections(), get2CP(), getErrata())
work offline.
