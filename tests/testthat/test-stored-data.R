test_that("errata table is well formed", {
  errata <- getErrata()
  expect_named(errata, c("table", "key", "field", "handbook_value", "corrected_value",
                         "issue", "evidence", "source", "date_added"))
  expect_false(anyNA(errata[, c("table", "key", "field", "handbook_value", "corrected_value")]))
  expect_false(any(duplicated(errata[, c("table", "key", "field")])))
})

test_that("getParlService returns parsed dates and flags overlaps", {
  ten <- getParlService("all")
  expect_s3_class(ten$DateStart, "Date")
  expect_false(any(ten$DateEnd %in% as.Date("1900-01-01")))
  calwell <- ten[ten$PHID == "BV8" & ten$DateStart == as.Date("1946-06-28"), ]
  expect_equal(nrow(calwell), 1)
  expect_match(calwell$handbook_flag, "overlapping_term")
  expect_false(is.null(attr(ten, "scraped")))
})

test_that("apply_errata removes the overlaps it corrects", {
  ten <- getParlService("all", apply_errata = TRUE)
  expect_false(any(ten$PHID == "BV8" & ten$DateStart == as.Date("1946-06-28")))
  overlapping <- grepl("overlapping_term", ten$handbook_flag) &
    !grepl("[corrected]", ten$handbook_flag, fixed = TRUE)
  expect_equal(sum(overlapping), 0)
})

test_that("getParlService filters by chamber", {
  expect_false("MemberOrSenator" %in% names(getParlService("house")))
  expect_error(getParlService("lords"))
})

test_that("getPartyService flags same-day records", {
  ps <- getPartyService()
  expect_s3_class(ps$DateStart, "Date")
  burston <- ps[ps$PHID == "207807" & ps$Party == "Independent", ]
  expect_match(burston$handbook_flag, "same_day_party_record")
})

test_that("getElections covers recent elections with Handbook ids", {
  e <- suppressMessages(getElections("all", byelections = TRUE))
  expect_true(all(c(2022, 2025) %in% e$Year[e$Division == "Federal"]))
  expect_true(all(c("Aston", "Fadden", "Dunkley", "Cook") %in% e$Division[e$Year >= 2023]))
  expect_false(any(duplicated(e$Id)))
  expect_equal(e$handbook_flag[e$Id == 9003], "not_in_handbook")

  fixed <- suppressMessages(getElections("all", byelections = TRUE, apply_errata = TRUE))
  expect_equal(fixed$DateElection[fixed$Id == 9004], as.Date("1945-08-18"))
  expect_error(getElections(), "chamber must be specified")
})

test_that("get2CP has at most one result pair per division and election", {
  two <- suppressMessages(get2CP())
  expect_true(all(c(2022, 2025) %in% two$Year))
  per_division <- table(paste(two$Year, two$Name))
  expect_true(all(per_division <= 2))
  expect_gt(mean(per_division == 2), 0.99)
})
