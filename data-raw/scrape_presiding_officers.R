# Build the stored presiding officers table:
# inst/extdata/presiding_officers.Rdata.
# Uses the same function as getPresidingOfficers(update = TRUE), so stored and
# updated data match. Run from the package root. One request.

devtools::load_all()

data<-handbook_presiding_officers()
if(is.null(data)) stop("Could not reach the Handbook API.")
attr(data, "scraped")<-as.character(Sys.Date())
save(list=c("data"), file="inst/extdata/presiding_officers.Rdata")
