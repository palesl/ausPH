# updating the stored tables from the Handbook
skip_on_cran()
skip_if_offline("handbookapi.aph.gov.au")

test_that("getParlService retrieves the whole table live", {
  live <- getParlService("all")
  stored <- getParlService("all", update = FALSE)
  expect_equal(attr(live, "scraped"), as.character(Sys.Date()))
  expect_gte(nrow(live), nrow(stored))
  expect_named(live, names(stored))
})

test_that("getElections and get2CP add nothing twice", {
  e <- suppressMessages(getElections("all", byelections = TRUE))
  expect_false(any(duplicated(e$Id)))
  expect_false(is.null(attr(e, "updated")))
  two <- suppressMessages(get2CP(include_byelections = TRUE))
  expect_false(is.null(attr(two, "updated")))
  per_division <- table(paste(two$ElectionID, two$Name))
  expect_true(all(per_division <= 2))
})

test_that("a new general election's 2CP is fetched like the stored copy", {
  main <- readr::read_csv(system.file("extdata", "main_elections_2cp.csv", package = "ausPH"),
                          show_col_types = FALSE)
  by_elect <- readr::read_csv(system.file("extdata", "by_elections_2cp.csv", package = "ausPH"),
                              show_col_types = FALSE)
  # pretend the 2025 election (Id 418) is not stored yet
  new <- suppressMessages(new_2cp(main[main$ElectionID != 418, ], by_elect, FALSE))
  stored_2025 <- main[main$ElectionID == 418, ]
  expect_equal(nrow(new$main), nrow(stored_2025))
  expect_equal(sort(new$main$votes_2cp), sort(stored_2025$votes_2cp))
})

test_that("party service is fetched in the stored layout", {
  people <- data.frame(PHID = c("207807", "IG4"), DisplayName = c("BURSTON, Brian", "VALLENTINE, Josephine"))
  fresh <- handbook_party_service(people)
  stored <- load_extdata("partyService_raw.Rdata")
  expect_named(fresh, names(stored))
  expect_equal(sort(paste(fresh$PHID, fresh$Party, fresh$DateStart)),
               sort(paste(stored$PHID, stored$Party, stored$DateStart)[stored$PHID %in% people$PHID]))
})
