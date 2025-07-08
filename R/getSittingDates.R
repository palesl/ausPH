#' data on sitting dates in the federal parliament
#'
#'
#'
#' @return a tibble
#' @export
#'
#' @examples getSittingDates()
getSittingDates<-function(){
    older <-system.file("extdata", "sitting_dates1901_2022.Rdata", package = "ausPH")
    load(older)

    saved<-list()
    j<-1
    for(i in 2023:as.numeric(substr(Sys.Date()|>as.character(),1,4))){
      print(i)
      url<-paste0("https://handbookapi.aph.gov.au/api/StatisticalInformation/SittingDaysForYear?year=", i)
      working<-rjson::fromJSON(file=url)|>dplyr::bind_rows()
      working$year_id<-paste(i,working$`$id`, sep="_")
      working<-working[,-1]
      saved[[j]]<-working
      j<-j+1
    }
    newer<-dplyr::bind_rows(saved)

    out<-dplyr::bind_rows(saved_out,newer)
}

#
# saved<-list()
# j<-1
# for(i in 1901:2022){
#   print(i)
#   url<-paste0("https://handbookapi.aph.gov.au/api/StatisticalInformation/SittingDaysForYear?year=", i)
#   working<-rjson::fromJSON(file=url)|>dplyr::bind_rows()
#   working$year_id<-paste(i,working$`$id`, sep="_")
#   working<-working[,-1]
#   saved[[j]]<-working
#   j<-j+1
# }
# saved_out<-dplyr::bind_rows(saved)
# save(saved_out, file = "inst/extdata/sitting_dates1901_2022.Rdata")
