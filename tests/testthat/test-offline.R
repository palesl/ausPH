# when the Handbook cannot be reached, updates fall back to the stored copy
test_that("updates fall back to the stored copy when the API is unreachable", {
  local_mocked_bindings(fetch_handbook = function(endpoint, quiet = FALSE) NULL)

  expect_message(ten <- getParlService("all"), "stored copy")
  expect_equal(attr(ten, "scraped"), attr(load_extdata("tenures_raw.Rdata"), "scraped"))

  expect_message(e <- getElections("all"), "stored copy")
  expect_null(attr(e, "updated"))

  expect_message(two <- get2CP(), "Notes contain")
  expect_null(attr(two, "updated"))

  expect_message(s <- getSittingDates(), "stored copy")
  expect_null(attr(s, "updated"))

  expect_message(ps <- getPartyService(update = TRUE), "stored copy")
  expect_null(attr(ps, "updated"))
})
