.onLoad <- function(libname, pkgname) {
  if (getRversion() >= "2.15.1") {
    utils::globalVariables(c("area",
                             "area_name",
                             "area_id",
                             "cycle",
                             "space",
                             "CYCLE",
                             "URL",
                             "."
                             ))
  }
}
