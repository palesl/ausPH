# Scrape sitting dates for every complete year since 1901.
# getSittingDates() fetches the current year and later from the API.
# Writes inst/extdata/sitting_dates.Rdata. Run from the package root.

last_year<-as.numeric(format(Sys.Date(), "%Y")) - 1

saved<-list()
for(i in 1901:last_year){
  url<-paste0("https://handbookapi.aph.gov.au/api/StatisticalInformation/SittingDaysForYear?year=", i)
  saved[[length(saved)+1]]<-rjson::fromJSON(file=url)|>dplyr::bind_rows()
}
sitting_dates<-dplyr::bind_rows(saved)|>dplyr::select(-`$id`)
attr(sitting_dates, "scraped")<-as.character(Sys.Date())

save(sitting_dates, file="inst/extdata/sitting_dates.Rdata")
