test_that("parse_handbook_date reads every Handbook date format", {
  expect_equal(parse_handbook_date(c("2001-11-10", "2001-11-10T00:00:00",
                                     "10/11/2001 12:00:00 AM")),
               as.Date(rep("2001-11-10", 3)))
})

test_that("1900-01-01 placeholders become NA", {
  expect_true(is.na(parse_handbook_date("1900-01-01T00:00:00")))
  expect_equal(is_placeholder_date(c("1900-01-01T00:00:00", "1901-01-01", NA)),
               c(TRUE, FALSE, FALSE))
})

test_that("add_flag accumulates codes once each", {
  flag <- add_flag(c(NA, "a"), c(TRUE, TRUE), "b")
  expect_equal(flag, c("b", "a; b"))
  expect_equal(add_flag(flag, c(TRUE, TRUE), "b"), flag)
  expect_equal(add_flag("b [corrected]", TRUE, "b"), "b [corrected]")
})

test_that("records_to_tibble keeps records with empty or nested fields", {
  records <- list(list(`$id` = "1", Id = 1, Parties = list()),
                  list(`$id` = "2", Id = 2, Name = NULL, Parties = list(list(Id = 4))))
  out <- records_to_tibble(records)
  expect_equal(nrow(out), 2)
  expect_equal(names(out), c("Id", "Name")[seq_len(ncol(out))])
})

test_that("errata are flagged by default and applied on request", {
  dat <- data.frame(Date = as.Date(c("1928-03-14", "1928-03-15")),
                    SenateSitting = c(TRUE, TRUE), handbook_flag = NA_character_)
  keys <- as.character(dat$Date)

  flagged <- apply_errata_table(dat, "sitting_dates", keys, apply_errata = FALSE)
  expect_equal(flagged$SenateSitting, c(TRUE, TRUE))
  expect_equal(flagged$handbook_flag, c("chamber_did_not_sit", NA))

  corrected <- apply_errata_table(dat, "sitting_dates", keys, apply_errata = TRUE)
  expect_equal(corrected$SenateSitting, c(FALSE, TRUE))
  expect_equal(corrected$handbook_flag, c("chamber_did_not_sit [corrected]", NA))
})

test_that("an erratum lapses once the Handbook value changes", {
  dat <- data.frame(Date = as.Date("1928-03-14"), SenateSitting = FALSE,
                    handbook_flag = NA_character_)
  out <- apply_errata_table(dat, "sitting_dates", "1928-03-14", apply_errata = TRUE)
  expect_equal(out$handbook_flag, NA_character_)
})
