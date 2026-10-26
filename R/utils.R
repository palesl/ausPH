# internal helpers shared by the get* functions

handbook_api <- "https://handbookapi.aph.gov.au/api/"

# fetch a Handbook API endpoint and return the parsed JSON, or NULL with a
# message (unless quiet) if the API cannot be reached
fetch_handbook <- function(endpoint, quiet = FALSE){
  out <- tryCatch(
    suppressWarnings(rjson::fromJSON(file = paste0(handbook_api, endpoint))),
    error = function(e) NULL
  )
  if (is.null(out) && !quiet) {
    message("Could not retrieve '", endpoint, "' from the Parliamentary Handbook API (",
            handbook_api, "). The service may be unavailable; please try again later.")
  }
  out
}

# turn a list of API records into a tibble: NULLs become NA and nested lists
# (e.g. Parties inside a ministry) are dropped, so no record is lost or repeated
records_to_tibble <- function(records){
  records <- lapply(records, function(r){
    r <- r[!vapply(r, is.list, logical(1))]
    r <- lapply(r, function(v) if (is.null(v) || length(v) == 0) NA else v)
    r[names(r) != "$id"]
  })
  dplyr::bind_rows(records)
}

# parse the date formats the Handbook has used over time:
# "2001-11-10", "2001-11-10T00:00:00" and "10/11/2001 12:00:00 AM".
# 1900-01-01 is the Handbook's placeholder for a missing date, so it becomes NA.
parse_handbook_date <- function(x){
  x <- as.character(x)
  x <- trimws(sub("T.*$| 12:00:00 AM$", "", x))
  out <- as.Date(x, format = "%Y-%m-%d")
  dmy <- is.na(out) & grepl("^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$", x)
  out[dmy] <- as.Date(x[dmy], format = "%d/%m/%Y")
  out[out %in% as.Date("1900-01-01")] <- NA
  out
}

# TRUE where the raw value is the Handbook's 1900-01-01 placeholder
is_placeholder_date <- function(x){
  substr(as.character(x), 1, 10) %in% "1900-01-01"
}

# load an .Rdata file from inst/extdata and return the single object inside it
load_extdata <- function(file){
  env <- new.env()
  objects <- load(system.file("extdata", file, package = "ausPH"), envir = env)
  env[[objects[1]]]
}

# add a flag to rows: flags accumulate as "code1; code2", each code once
add_flag <- function(flag, rows, code){
  rows <- rows & !is.na(rows)
  has_code <- vapply(strsplit(ifelse(is.na(flag), "", flag), "; ", fixed = TRUE),
                     function(f) any(sub(" \\[corrected\\]$", "", f) == code), logical(1))
  rows <- rows & !has_code
  flag[rows] <- ifelse(is.na(flag[rows]), code, paste(flag[rows], code, sep = "; "))
  flag
}

# flag (and optionally correct) rows listed in the errata table.
# `keys` is the key string for each row of `dat`, built the same way as
# errata$key for that table. An erratum only applies while the Handbook still
# has the value it was written against, so it lapses once the Handbook is fixed.
apply_errata_table <- function(dat, table, keys, apply_errata){
  errata <- getErrata()
  errata <- errata[errata$table == table, ]

  for (i in seq_len(nrow(errata))) {
    field <- errata$field[i]
    rows <- which(keys == errata$key[i] &
                    as.character(dat[[field]]) == errata$handbook_value[i])
    if (length(rows) == 0) next

    code <- errata$issue[i]
    if (apply_errata) {
      new_value <- errata$corrected_value[i]
      if (inherits(dat[[field]], "Date")) new_value <- as.Date(new_value)
      if (is.logical(dat[[field]])) new_value <- as.logical(new_value)
      dat[[field]][rows] <- new_value
      code <- paste0(code, " [corrected]")
    }
    dat$handbook_flag <- add_flag(dat$handbook_flag, seq_len(nrow(dat)) %in% rows, code)
  }
  dat
}

# one row per person and value of a list field on the individuals endpoint,
# dropping people with no entry
individual_list_field <- function(fields, value_name){
  dat <- fetch_handbook("individuals")$value
  if (is.null(dat)) return(NULL)
  rows <- lapply(dat, function(element){
    values <- unique(unlist(element[fields]))
    values <- values[!is.na(values) & trimws(values) != ""]
    data.frame(PHID = rep(element[["PHID"]], length(values)), value = values,
               stringsAsFactors = FALSE)
  })
  out <- dplyr::as_tibble(do.call(rbind, rows))
  names(out)[2] <- value_name
  out
}

# date a stored CSV table was last built from the Handbook
# (the .Rdata tables carry this as an attribute instead)
stored_scrape_date <- function(table){
  dates <- utils::read.csv(system.file("extdata", "scrape_dates.csv", package = "ausPH"),
                           colClasses = "character")
  dates$scraped[dates$table == table]
}

# record a table's build date in inst/extdata/scrape_dates.csv; used by the
# scripts in data-raw/, run from the package root
record_scrape_date <- function(table, date = Sys.Date()){
  file <- "inst/extdata/scrape_dates.csv"
  dates <- utils::read.csv(file, colClasses = "character")
  dates <- dates[dates$table != table, ]
  dates <- rbind(dates, data.frame(table = table, scraped = as.character(date)))
  utils::write.csv(dates, file, row.names = FALSE, quote = FALSE)
}
