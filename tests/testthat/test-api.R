# these functions query the Handbook API, so only run when online
skip_on_cran()
skip_if_offline("handbookapi.aph.gov.au")

test_that("ministry and shadow ministry dates parse", {
  m <- getMinisters()
  expect_s3_class(m$MDateStart, "Date")
  expect_lt(mean(is.na(m$MDateStart)), 0.05)
  sm <- getShadowMinisters()
  expect_lt(mean(is.na(sm$MDateStart)), 0.05)
})

test_that("getMinistries keeps ministries with no listed party", {
  mi <- getMinistries()
  expect_true(1 %in% mi$MinistryNumber)
  expect_true("pID" %in% names(mi))
})

test_that("getParties trims whitespace", {
  p <- getParties()
  expect_false(any(grepl("^\\s|\\s$", p$Abbrev[!is.na(p$Abbrev)])))
})

test_that("getSittingDates returns dates and flags errata", {
  s <- getSittingDates()
  expect_s3_class(s$Date, "Date")
  expect_false(any(duplicated(s$Date)))
  expect_equal(s$handbook_flag[s$Date == as.Date("1997-03-17")], "chamber_did_not_sit")
})

test_that("committee end dates parse", {
  cm <- getCommitteeMembers()
  expect_s3_class(cm$end_date, "Date")
  expect_false(any(cm$end_date %in% as.Date("1900-01-01")))
})
