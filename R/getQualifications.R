#' Data on all listed Qualifications
#' @return a list
#' @export
#'
#' @examples getQualifications()
getQualifications<-function(){
  url<- "https://handbookapi.aph.gov.au/api/individuals"
  dat<-rjson::fromJSON(file=url)$value

  result_df <- data.frame(PHID = character(), Qualification = character(), stringsAsFactors = FALSE)

  # Loop through each element of the list
  for (element in dat) {
    # Extract PHID and Occupations
    phid <- element[["PHID"]]
    quals <- element[["Qualifications"]]


    # Create a temporary data frame for the current element
    temp_df <- data.frame(PHID = rep(phid, length(quals)), Qualification = quals, stringsAsFactors = FALSE)

    # Append the temporary data frame to the result data frame
    result_df <- rbind(result_df, temp_df)
  }


  return(result_df)
}
