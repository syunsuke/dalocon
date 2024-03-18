#' Make table number 15 data tidy
#'
#' @param df data.frame
#'
#' @return data.frame
#' @export
dalocon_make_t15_tidy <- function(df){
  ans <- df %>%
    tidyr::pivot_longer(
      cols = !(area_name:cycle),
      names_to = c("cat02","cat01","tab"),
      names_sep = "_",
      values_to = "value"
    ) %>%
    dplyr::mutate(
      `利用関係` = t15_cat01_value[.$cat01],
      `工事`     = t15_cat02_value[.$cat02]
                  )

  return(ans)
}

#############################
# 利用関係 cat01
#############################
t15_cat01_name <-
  c("t",
    "own",
    "rent",
    "com",
    "fam")

t15_cat01_value <-
  c("計",
    "持家",
    "貸家",
    "給与住宅",
    "分譲住宅")

names(t15_cat01_value) <- t15_cat01_name

###############################
# 工事 cat02
###############################
t15_cat02_name <-
  c("t",
    "new",
    "other")

t15_cat02_value <-
  c("計",
    "新設",
    "その他")

names(t15_cat02_value) <- t15_cat02_name

