#' Data on all listed prior occupations held (both primary and secondary)
#' @return a list
#' @export
#'
#' @examples getOccupation()
getOccupation<-function(){
  url<- "https://handbookapi.aph.gov.au/api/individuals"
  dat<-rjson::fromJSON(file=url)$value

  result_df <- data.frame(PHID = character(), Occupation = character(), stringsAsFactors = FALSE)

  # Loop through each element of the list
  for (element in dat) {
    # Extract PHID and Occupations
    phid <- element[["PHID"]]
    occupations <- element[["Occupations"]]

    occupations<-c(occupations,element[["SecondaryOccupations"]])|>unlist()|>unique()

    # Create a temporary data frame for the current element
    temp_df <- data.frame(PHID = rep(phid, length(occupations)), Occupation = occupations, stringsAsFactors = FALSE)

    # Append the temporary data frame to the result data frame
    result_df <- rbind(result_df, temp_df)
  }


  return(result_df)
}


