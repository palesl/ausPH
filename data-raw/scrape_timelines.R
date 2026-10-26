# Build the stored parliamentary service and party service tables:
# inst/extdata/tenures_raw.Rdata and inst/extdata/partyService_raw.Rdata.
# Uses the same functions as getParlService(update = TRUE) and
# getPartyService(update = TRUE), so stored and updated data match.
# Run from the package root. Parliamentary service is one request; party
# service is one request per person (about 25 minutes).

devtools::load_all()

scraped<-as.character(Sys.Date())

data<-handbook_parl_service()
if(is.null(data)) stop("Could not reach the Handbook API.")
attr(data, "scraped")<-scraped
save(list=c("data"), file="inst/extdata/tenures_raw.Rdata")

individuals<-records_to_tibble(fetch_handbook("individuals?$select=PHID,DisplayName")$value)
data<-handbook_party_service(individuals, progress=TRUE)

# stop rather than save a partial scrape
failed<-attr(data, "failed")
if(length(failed)>0) stop("Failed to fetch: ", paste(failed, collapse=", "), ". Re-run.")

attr(data, "failed")<-NULL
attr(data, "scraped")<-scraped
save(list=c("data"), file="inst/extdata/partyService_raw.Rdata")
