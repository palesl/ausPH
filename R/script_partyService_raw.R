# # # script_partyServiceRaw.R
# # # last scraped: 9 Mar 2024

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
#
#   dat<-dat$PartyService|>dplyr::bind_rows()|>
#     dplyr::bind_cols(individuals[i,])|>
#     dplyr::select(-`$id`)
#
#   list[[i]]<- dat
# }
#
# data<-dplyr::bind_rows(list)
#
# save(list=c("data"), file="inst/extdata/partyService_raw.Rdata")
#
#


