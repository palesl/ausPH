# Helpers for the scripts in data-raw/, which build the data stored in
# inst/extdata/. They write into the package source, so they are kept out of
# the package itself (CRAN does not allow package code to write to the
# user's filespace). Source this file from the package root.

# record a table's build date in inst/extdata/scrape_dates.csv
record_scrape_date <- function(table, date = Sys.Date(),
                               file = "inst/extdata/scrape_dates.csv"){
  dates <- utils::read.csv(file, colClasses = "character")
  dates <- dates[dates$table != table, ]
  dates <- rbind(dates, data.frame(table = table, scraped = as.character(date)))
  utils::write.csv(dates, file, row.names = FALSE, quote = FALSE)
}
