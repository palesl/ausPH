#' Data on all listed prior occupations held (both primary and secondary)
#' @return a data frame with one row per person and occupation
#' @export
#'
#' @examples
#' \donttest{
#' getOccupations()
#' }
getOccupations<-function(){
  individual_list_field(c("Occupations","SecondaryOccupations"), "Occupation")
}
