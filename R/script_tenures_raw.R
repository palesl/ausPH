# # scrape_for_Tenures.R
# # last scraped: 13 December 2022
#
# individuals<- ausPH::getIndividuals()|> dplyr::select(1:2)
#
# list<- list()
#
# for(i in 1:nrow(individuals)){
#
#   print(paste(i, "out of", nrow(individuals)))
#   url<- paste0("https://handbookapi.aph.gov.au/api/Parliamentarian/GetTimeline?id=", individuals$PHID[i])
#   dat<- rjson::fromJSON(file=url)
#
#   dat<-dat$ParliamentaryService|>dplyr::bind_rows()|>
#     dplyr::bind_cols(individuals[i,])|>
#     dplyr::select(-`$id`)
#
#   list[[i]]<- dat
#
#   data<-dplyr::bind_rows(list)
#
#   save(list=c("data"), file="inst/extdata/tenures_raw.Rdata")
#
# }
#
#
