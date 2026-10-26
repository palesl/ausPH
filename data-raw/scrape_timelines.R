# Scrape parliamentary service (tenures) and party service for every
# individual in the Handbook, from the Parliamentarian/GetTimeline endpoint.
# Writes inst/extdata/tenures_raw.Rdata and inst/extdata/partyService_raw.Rdata.
# Run from the package root. Takes about 40 minutes (one request per person).

individuals<- rjson::fromJSON(file="https://handbookapi.aph.gov.au/api/individuals?$select=PHID,DisplayName")$value|>
  dplyr::bind_rows()

# NULLs become NA so that every record keeps all of its fields
as_tibble_records<-function(records, person){
  dat<-lapply(records, function(r) lapply(r, function(v) if(is.null(v)) NA else v))|>
    dplyr::bind_rows()
  if(nrow(dat)==0) return(NULL)
  dplyr::bind_cols(dat, person[rep(1, nrow(dat)),])|>dplyr::select(-`$id`)
}

tenures<- list()
party<- list()
failed<- character()

for(i in seq_len(nrow(individuals))){
  if(i %% 100 == 0) print(paste(i, "out of", nrow(individuals)))
  url<- paste0("https://handbookapi.aph.gov.au/api/Parliamentarian/GetTimeline?id=", individuals$PHID[i])
  dat<- tryCatch(rjson::fromJSON(file=url), error=function(e) NULL)
  if(is.null(dat)){
    failed<-c(failed, individuals$PHID[i])
    next
  }
  tenures[[i]]<- as_tibble_records(dat$ParliamentaryService, individuals[i,])
  party[[i]]<- as_tibble_records(dat$PartyService, individuals[i,])
}

# stop rather than save a partial scrape
if(length(failed)>0) stop("Failed to fetch: ", paste(failed, collapse=", "), ". Re-run.")

scraped<-as.character(Sys.Date())

data<-dplyr::bind_rows(tenures)
attr(data, "scraped")<-scraped
save(list=c("data"), file="inst/extdata/tenures_raw.Rdata")

data<-dplyr::bind_rows(party)
attr(data, "scraped")<-scraped
save(list=c("data"), file="inst/extdata/partyService_raw.Rdata")
