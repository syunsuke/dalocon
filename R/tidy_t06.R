#' Make table number 06 data tidy
#'
#' @param df data.frame
#'
#' @return data.frame
#' @export
dalocon_make_t06_tidy <- function(df){
  ans <- df %>%
    tidyr::pivot_longer(
      cols = !(area_name:cycle),
      names_to = c("cat01","tab"),
      names_sep = "_",
      values_to = "value"
    ) %>%
    dplyr::mutate(
      `構造` = t06_cat01_value[.$cat01])

  return(ans)
}

#############################
# 利用関係 cat01
#############################
t06_cat01_name <-
  c("t",
    "w","src","rc","s","cb","other")
t06_cat01_value <-
  c("計",
    "木造",
    "鉄骨鉄筋コンクリート造",
    "鉄筋コンクリート造",
    "鉄骨造",
    "コンクリートブロック造",
    "その他")

names(t06_cat01_value) <- t06_cat01_name

