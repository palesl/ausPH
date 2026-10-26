#' Data on all listed Secondary Schools
#' @return a data frame with one row per person and school, as listed in the
#'   Handbook (some entries name more than one school)
#' @export
#'
#' @examples
#' \donttest{
#' getSchools()
#' }
getSchools<-function(){
  individual_list_field("SecondarySchool", "secondary_school")
}
