# strsplit1, a nod to paste0 but for the very annoying str_split function

strsplit1 <- function(x, split) {
  strsplit(x, split = split)[[1]]
}
