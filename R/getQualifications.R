#' Data on all listed Qualifications
#' @return a tibble with one row per person and qualification
#' @export
#'
#' @examples
#' \donttest{
#' getQualifications()
#' }
getQualifications<-function(){
  individual_list_field("Qualifications", "Qualification")
}
