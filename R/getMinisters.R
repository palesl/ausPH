#' Data on Ministers since 1901
#' @return a tibble with one row per ministerial role. `RDateStart` and
#'   `RDateEnd` are the dates of the role; `MDateStart` and `MDateEnd` are the
#'   dates of the ministry.
#' @export
#'
#' @examples
#' \donttest{
#' getMinisters()
#' }
getMinisters<-function(){
  raw<-fetch_handbook("ministryrecords")
  if(is.null(raw)) return(NULL)
  dat<-records_to_tibble(raw[["value"]])
  for(col in c("RDateStart","RDateEnd","MDateStart","MDateEnd")){
    dat[[col]]<-parse_handbook_date(dat[[col]])
  }
  dat
}
